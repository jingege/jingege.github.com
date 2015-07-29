---
layout: post
date: 2013-09-22 20:10:15
title: 记一次Hive线上问题的排查
categories: [技术]
tags: [Hive]
---

前几天监控到一个Hive Job CPU偏高，而且长时间无法停止，我最初怀疑是死循环，于是着手排查了下问题，不算太曲折。虽然已经过去多日，细节都快忘了，不过幸亏chrome的history里保留了一些痕迹，让我能把这件事分享出来。

由于权限有限，只能从运行Hive Job的这台机器查起。首先是要查看下对应的java进程的运行状况，用jstack，失败，抛出如下异常：

```sun.jvm.hotspot.debugger.DebuggerException: sun.jvm.hotspot.debugger.DebuggerException: get_thread_regs failed for a lwp```

首次见到，于是google之，得知是JDK6u23之前的一个bug（参考[这里](http://www.blogjava.net/hankchen/archive/2012/04/09/373640.html)），查看了下故障机的JDK版本，果然低了，奇怪的是只有这台比较低，先不管，升级到1.6.0_31。

继续jstack，发现没有异常的锁等待。多次jstack查看，主线程都在这个方法里（代码行偶尔不同）：

```org.apache.hadoop.mapred.lib.CombineFileInputFormat.getMoreSplits(JobConf, Path[], long, long, long, List<CombineFileSplit>)```

于是基本确定是在上述方法里发生了死循环，于是继续搜索：`hadoop getMoreSplits infinite loop`，发现社区有个相关的[issue](https://issues.apache.org/jira/browse/MAPREDUCE-2862)。关键是这句话：

>At first, we lost some blocks by mis-operation . Then, one job tried to use these missing blocks. At that time getMoreSplits() goes into the infinite loop.

上面是因为mis-operation导致的，我没有听说有误操作发生，于是去读代码，同时汇报进展，同事听后告诉我确有一台DataNode挂掉了，那么如果确实是一台DataNode的宕机导致了block missing，则相关文件的replication应该为1，继续hadoop fs查看相关文件的replication，果不其然。

虽然不是十分明确地指出事故原因，但从一系列的分析来看，基本可以断定是上述原因。读了下上述issue提交的patch，大概的思路是在while(true)中检测是否出现了上述情况，如果出现的话，则强行忽略掉出问题的block，起初我还试图把这个patch打进来，但转念一想，这样会导致出现数据丢失，根本就不治本，问题的实质不是hadoop的错，而是hadoop的使用者没能很好地理解HDFS，在hadoop的世界里，错误是常态，虽然hadoop允许将replication设置为1，但用户必须明白的是hadoop没有义务也没有能力确保用户数据万无一失，用户必须学会通过设置合适的参数来避免单点问题。最终我给出了两条建议：

* 严禁用户将replication设置为1
* 加强线上机器监控
