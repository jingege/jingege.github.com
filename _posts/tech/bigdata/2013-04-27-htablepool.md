---
layout: post
date: 2013-04-27 15:50:45
title: HTablePool简析
categories: [bigdata]
tags: [hbase]
published: false
summary: HTablePool源码的简单分析
---

HTablePool的必要性主要针对如下两点：

* HTable对象的初始化比较耗时
* HTable不是threadsafe的，主要是受制于Write Buffer

先看构造函数：

{% highlight java %}
public HTablePool(final Configuration config, final int maxSize, final HTableInterfaceFactory tableFactory, PoolType poolType)
{% endhighlight %}

本文着重关注下maxSize和poolType这两个参数：

- 啊

- b


