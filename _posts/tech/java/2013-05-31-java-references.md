---
layout: post
date: 2013-05-31 14:43:40
title: 简析Java Reference
categories: [programming]
tags: [java]
published: true
summary: 抽时间仔细看了下Java Reference相关的源代码，简单记一笔
---

Coding了多年Java，自然早就听说过四种引用类型，不过偶尔也才浅浅的用一下，今天突然想看看这块的内部实现，读了读jdk源码，这篇文章就当做个笔记。先简单介绍下四种引用类型：

####Java的四种引用类型####

*StrongReference*

强引用。最常见的引用类型，用赋值号，即“=”来创建。GC不会回收强引用，即使内存不足，也是宁可抛OOM先。

*SoftReference*

软引用。关键看内存，在内存不足时，GC会把软引用的对象回收掉。适用于对内存敏感的缓存。

*WeakReference*

弱引用。和软引用的区别是，无论内存充足与否，GC扫描到弱引用所引用的对象不再具有强引用时，会将其回收。

*PhantomReference*

虚引用，也称幽灵引用。其get()方法固定return null，看起来似乎没有什么大的用处，但在某些场景下结合ReferenceQueue，可以有意想不到的效果。

####ReferenceQueue####
站在coder的角度看，ReferenceQueue似乎更“有用”一些。其作用是追踪被gc的Reference对象，更多的是做一些统计或清理的工作。

####Reference的四种内部状态和ReferenceHandler####

Reference依赖内部的四种状态，和GC、ReferenceHandler配合来运作，包括：Active、Pending、Enqueued和Inactive，具体可以查看下Reference类的注释，鉴于笔者理解不足够深刻，就不误导大家了。

ReferenceHandler是个高优先级的线程，用于把gc处理的Reference对象enqueue到ReferenceQueue中。


近期使用SoftReference自己做了个缓存工具，用以缓存一定size的Hive查询结果，代码[在这里](https://gist.github.com/jingege/6060151)。