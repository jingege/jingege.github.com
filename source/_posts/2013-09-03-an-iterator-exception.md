---
layout: post
date: 2013-09-03 12:03:40
title: 记一个Iterator的异常
categories: [技术]
tags: [Java]
---

今天在一个熟悉的场景首次遇到了异常，在使用ArrayList的Iterator时，抛出了`java.lang.IllegalStateException`。仔细分析后，发现是一个不合适的循环嵌套，导致了`it.remove()`连续调用了两次。结合源码看了下，`AbstractList$Itr`类使用了一个`int lastRet`变量标记最近一次`next()`所指向的元素，而在调用`it.remove()`时，先检查lastRet的值，如果为-1，则抛出`IllegalStateException`，否则将lastRet置为-1。用以保证一个元素只被remove一次。在Itr类的子类ListIterator里，`previous()`也是同样原理。

古人云：

> 吃一堑长一智

又云：

> 学如逆水行舟，不进则退

重点在吃和行两个字，讲究行动，一定要在实践中遇到困难，并解决，方能长一智，方能前进。对于码农，则一定是要多动手，多碰钉子，多独立解决问题，如是自勉。
