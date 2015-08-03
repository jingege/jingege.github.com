---
layout: post
title: "[备忘]记一次使用Btrace排查线上问题"
date: 2015-08-02 11:01:13
tags: 
  - Btrace
  - Jumper
  - MQ
  - 备忘
---

本文仅供博主备忘。

#### 背景

我目前负责我司的分布式消息队列产品，某日，有业务方上报可能发生少量数据丢失，事态紧急，赶紧排查！

#### 验证问题

观察监控曲线，发现15分钟动态监控报表的生产和消费确实有数量上的差异，丢失的不算少。这里要说明一下，一般来说如果生产消费是持续不断的，是很难通过此类报表判断出数据丢失，因为消费是有延迟的，统计会在时间维度上产生错位，幸运的是此业务方的消息是定时发送的，大概是一两分钟一批，消费速度也很快，所以统计曲线看起来就像是一条条抛物线，丢不丢一算便知。


#### 检查各计数器和log

相关计数器正常，log也未发现任何疑点。

#### 思考

服务正常，但消息确实有少量丢失，而且受影响的topic似乎也极少，这个仅从表面看想必是很难看出原因了。考虑到消息的消费先是由`LeaderServer`分配ID段的，所以我决定祭上神器`Btrace`，线上抓取分配的ID和ACK表对比，力求找出蛛丝马迹。

#### 动手

脚本如下。

```java
@BTrace
public class GetMessageIDGreaterThan {
	@OnMethod(clazz = "com.yihaodian.architecture.jumper.common.inner.dao.impl.mongodb.MessageDAOImpl", method = "getMessageIDGreaterThan", location = @Location(Kind.RETURN))  
    public static void traceExecute(@ProbeClassName String name,@ProbeMethodName String method,String topicName, Long messageId,int size, int index,@Return Long ret){  
        if(BTraceUtils.compare(topicName,"dmp_user_creative_product")){
        	BTraceUtils.print(strcat("params","=>"));
        	BTraceUtils.print(strcat(topicName,","));
        	BTraceUtils.print(strcat(str(messageId),","));
        	BTraceUtils.print(strcat(str(size),","));
        	BTraceUtils.print(strcat(str(index),","));
        	BTraceUtils.println(strcat("result=>", str(ret)));
        }  
    }
}
```

其中，`messageId`是已经分配的最大ID，返回值`ret`是此次分配的最大ID。理论上，一系列输出应该是连续的。也即上一行的`ret`和此行的`messageId`是一致的。事实确实如此。

继续比对ACK表。解析一系列输出，写了个脚本输出了一堆mongo的查询语句，目的是查出哪些段的ID丢失了ack。经对比，一个奇怪的现象出现了，所有长度为264的ID段都丢失了。经检查，此数值乃JVM启动参数之一，即`-Dglobal.block.queue.fetchsize`，用来配置ConsumerServer批量获取消息的大小。为何这么巧合，丢失的都是长度为264的ID段呢？

表面淡定内心纠结地查了一通，发现了疑点，不是每台机器的`-Dglobal.block.queue.fetchsize`都一致，但最大的是就是264。这个比较意外，但想了想应该也不会出啥大问题啊。

更加糊涂了。

翻查代码，终于查找到元凶。如下，


```java
if (messageIDList != null && messageIDList.size() <= fetchSize) {
    //logic goes here
    return messageIDList;
}
```

其中，

```java
private final int fetchSize = Integer.parseInt(System.getProperty("global.block.queue.fetchsize", "200"));
```

问题找出来了，`LeaderServer`的配置是264，所以`ConsumerServer`拿到的ID段长度也是264，但本机的fetchSize比264要小，所以被直接忽略了。

那么问题是怎么产生的呢？导致问题的代码看似多余，其实也是一种自我保护。所以问题还是要归咎于配置不一致，引起逻辑上的混乱。那么为什么配置会不一致呢，原来前阵子SA为了方便使用`puppet`部署，将各种配置都参数化了，效果就是代码部署时，通过对硬件的计算，修改各种参数取值，这样就降低了运维的复杂度。虽然申请了一批硬件配置相同的机器，但是其“软配置”却各不相同，导致有些关键参数未能完全一致，而我又未能察觉隐患，故导致此问题。马上修改配置，重启，解决。

#### 反思

吃一堑长一智，这件事情的教训就是，类似问题很难保证完全避免，但在研发阶段就要多思考会导致问题的场景，及时写注释或记录到文档里。毕竟代码逻辑久了谁都会忘，但注释放那就会时刻提醒你不要犯错。当初如果在脚本的相关参数上备注：必须保证每台机器的此配置取值一致，问题也就不会发生了。