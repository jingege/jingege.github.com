---
layout: post
date: 2013-10-15 21:47:16
title: ketama的一个重要bug
categories: [技术]
tags:
	- Java
	- Hash
---
ketama是什么？

>C library for consistent hashing, and langauge bindings

至于consistent hasing（一致性哈希），不了解的可以参考[这里](http://en.wikipedia.org/wiki/Consistent_hashing)。

ketama是去年读[这篇文章](http://www.last.fm/user/RJ/journal/2007/04/10/rz_libketama_-_a_consistent_hashing_algo_for_memcache_clients)时看到的，应该是Richard Jones还在last.fm工作时写的，不过他现在已经离开了。今天莫名其妙地突然想起了它，所以特地又去搜了下，找到后顺便读了下源码。ketama最初是一个c库和一个PHP的封装，不过后来作者添加了多种其他语言的实现，还感慨Java集合类让实现简化了很多（实际上是用了SortedMap的API，我还读过一个常见的memcached java客户端，具体哪个忘了，也是用了SortedMap）。[源码](https://github.com/RJ/ketama)在github上可以看到。

问题就出在Java实现上。当我看到源码里声明了全局的`java.security.MessageDigest`时，意识到这里可能有并发问题。起初我还不太相信，于是去google了一把，网上似乎是说`MessageDigest`不是线程安全的，但我最后还是自己写了个简单的多线程程序测试以求最终确认，最后终于向自己证实确实是RJ同学出了bug。然后果断fork然后fix，最后向作者提交了patch，坐等处理。

我的patch很简单，将成员变量去掉，在函数中即时创建`MessageDigest`对象。为此我写了个简单的benchmark，发现`MessageDigest.getInstance(String)`方法在我的MBP MD313上一次调用耗时不足1ms，相对于网络开销来说基本可以忽略。

最后我去看了下apache-commons-codec库的`org.apache.commons.codec.digest.DigestUtils`类，发现也是类似的做法，遂放心。

类似的比较容易忽略的还有java.text.SimpleDateFormat,在编写Java类时，同学们一定要审慎对待每一个成员变量，以及其即将面临的运行环境。这其实很烦，这也是我喜欢FP的理由。
