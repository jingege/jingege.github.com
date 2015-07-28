---
layout: post
date: 2013-08-28 12:03:40
title: 对user.dir的误解
categories: [programming]
tags: [java]
published: true
summary: 澄清了一直以来对于user.dir的误解
---

今天调试程序的时候，发现我之前hard code的一段路径修改成了`System.getProperty("user.dir")`之后，依然可以正常运行。我一直以来都以为user.dir就是当前用户的home dir，似乎这个印象应该自大学时代就已经有了，所以我有些先入为主地认为是环境有问题。

我的程序是最终由一个py脚本调用jar包来执行，为了搞明白这个困惑的问题，我在java代码里插入了多处`out.println(System.getProperty("user.dir"))`，然后执行py，结果输出并非home dir。于是凭直觉将问题定位在py里的一句`os.chdir(sys.path[0]+"/..")`上。再然后我就写了个测试的Main函数，在控制台直接`java -cp a.jar path.to.Main`，果然输出了当前目录，于是问题清晰了。

于是网上查了下，竟然是我搞混了。如下摘自[jdk文档](http://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)：

>"user.dir"  User working directory

>"user.home"  User home directory

最后我也终于记起来为什么会有这个错误的印象了。大学时用java写了个简单的http server，创建配置文件时，我默认写在了user.home，所以有了这个印象。如今看到user.dir，便和user.home混淆起来。

都写这么多年java了，让大家见笑了。问题也搞清楚了，我发现以后遇到路径问题，借助`user.dir`和脚本，可以非常方便的解决了。