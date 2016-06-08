---
layout: post
title: "译文:@Contended和伪共享"
date: 2016-05-31 09:20:04
categories: [技术,翻译]
tags: [Java]
---

> 原文: http://robsjava.blogspot.com/2014/03/what-is-false-sharing.html

Java8引入了`@Contented`这个新的注解来减少伪共享(`False Sharing`)的发生。本文介绍了`@Contented`注解并解释了为什么`False Sharing`是如何影响性能的。

### 缓存行
CPU读取内存数据时并非一次只读一个字节，而是会读一段64字节长度的连续的内存块(chunks of memory)，这些块我们称之为缓存行(Cache line)。

假设你有两个线程(Thread1和Thread2)都会修改同一个`volatile`变量`x`:

```Java
volatile long x;
```

如果Thread1先改变x的值，然后Thread2又去读它：

```Java
Thread 1: x=3;  
Thread 2: System.out.print(x);
```

那么x所在缓存行上的所有64个字节的值都要被重新加载，因为CPU核心间交换数据是以缓存行为最小单位的。当然Thread1和Thread2是有可能在同一个核心上运行的，但我们此处假设两个线程在不同的核心上运行。

已知long类型占8个字节，缓存行长度为64个字节，那么一个缓存行可以保存8个long型变量，我们已经有了一个long型的x，假设x所在缓存行里还有其他7个long型变量，v1到v7:

```
x, v1, v2, v3, v4, v5 ,v6 ,v7
```

### 伪共享(False Sharing)
这个缓存行可以被许多线程访问。如果其中一个修改了v2，那么会导致Thread1和Thread2都会重新加载整个缓存行。你可能会疑惑为什么修改了v2会导致Thread1和Thread2重新加载该缓存行，毕竟只是修改了v2的值啊。虽然说这些修改逻辑上是互相独立的，但同一缓存行上的数据是统一维护的，一致性的粒度并非体现在单个元素上。这种不必要的数据共享就称之为“伪共享”(False Sharing)。

### 填充(Padding)

一个CPU核心在加载一个缓存行时要执行上百条指令。如果一个核心要等待另外一个核心来重新加载缓存行，那么他就必须等在那里，称之为`stall`(停止运转)。减少伪共享也就意味着减少了`stall`的发生，其中一个手段就是通过填充(Padding)数据的形式，来保证本应有可能位于同一个缓存行的两个变量，在被多线程访问时必定位于不同的缓存行。

在下面这个例子里，我们试图通过填充的方式，使得`x`和`v1`位于不同的缓存行：

```java
public class FalseSharingWithPadding {
    public volatile long x;
    public volatile long p2;   // padding
    public volatile long p3;   // padding
    public volatile long p4;   // padding
    public volatile long p5;   // padding
    public volatile long p6;   // padding
    public volatile long p7;   // padding
    public volatile long p8;   // padding
    public volatile long v1;
}
```
在你考虑使用填充之前，必须要了解的一点是JVM可能会清除无用字段或重排无用字段的位置，这样的话，可能无形中又会引入伪共享。我们也没有办法指定对象在堆内驻留的位置。

为了避免无用字段被消除，通常我们会用`volatile`修饰一下。个人建议只需为处于激烈竞争状态的类进行填充处理，而且一般只有通过对其性能分析才能发现性能上的不同。通常在性能分析时，最好在对其迭代访问10000次之后再去采样，这样可以消除JVM本身的运行时优化策略带来的影响。

### Java8和@Contended
除了对字段进行填充之外，还有一个比较清爽的方法，那就是对需要避免陷入伪共享的字段进行注解，这个注解暗示JVM应当将字段放入不同的缓存行，这也正是JEP142的相关内容。

该JEP引入了`@Contented`注解。被这个注解修饰的字段应当和其他的字段驻留在不同的位置。

```java
public class Point {
    int x;
    @Contended
    int y;
}
```
上面的代码将x和y置于不同的缓存行。@Contented注解将y移动到远离对象头部的地方，(以避免和x一起被加载到同一个缓存行)。

### 参考

http://openjdk.java.net/projects/jdk8/features
http://beautynbits.blogspot.co.uk/2012/11/the-end-for-false-sharing-in-java.html
http://openjdk.java.net/jeps/142
http://mechanical-sympathy.blogspot.co.uk/2011/08/false-sharing-java-7.html
http://stackoverflow.com/questions/19892322/when-will-jvm-use-intrinsics
https://blogs.oracle.com/dave/entry/java_contented_annotation_to_help
