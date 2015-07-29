---
layout: post
date: 2013-09-05 23:15:30
title: "[开源]DataX的oracle JDBC writer插件"
categories: [技术]
tags:
	- Java
	- 开源
	- DataX
---

项目地址：[https://github.com/jingege/datax-oraclejdbcwriter](https://github.com/jingege/datax-oraclejdbcwriter)

> 取之于开源，用之于开源

淘宝的DataX开源版本只提供了OCI方式的oracle writer plugin，部署起来有点麻烦。基于JDBC驱动的话，性能虽然不及OCI，但一般只要不是太苛刻的需求，还是能满足的。

DataX的插件机制让对其扩展变得十分简单，所以实现一个插件并非难事，而且笔者提交的代码也并不漂亮，故此次开源仅仅是作为对开源社区的一次微不足道的回馈，理所应当。
