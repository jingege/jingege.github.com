---
layout: post
date: 2013-09-16 19:03:02
title: Java堆外内存泄露场景总结
categories: [技术]
tags:
	- Java
---

去年在一次QA对我们的一台长连接服务器进行压测后，暴露了一个Java内存泄露问题，结合jconsole、jmap等一系列工具分析和代码review，最后发现是一个存放断开的Socket连接的容器，没有合适的清理释放逻辑。这是在java heap上发生的泄露，如果发生了non-heap上的内存泄露，一般会祭上`google-perftools`来分析。但不像堆上的泄露原因各种各样，non-heap的泄露原因比较常见的只有几种，因为日常开发中很少有机会操作non-heap内存。

这里总结一下java的non-heap内存泄露原因。其实说白了也就是介绍下日常开发中，哪里有可能接触到non-heap，哪些东西是放到non-heap上的。

####JNI

使用JNI有时为了提高效率，对于这种情况，如果效率提升不是非常大的话，我个人还是建议使用纯Java来替代JNI。正如我去年做的，兄弟部门把人脸识别的判决算法封装到JNI里，而我一向对自己写JNI不太放心，为了降低风险提高系统稳定性，干脆将核心算法翻译成Java了。但对于不得不使用JNI的场景，一定要注意内存的管理，但对于`NewStringUTF()`这种方法调用，则无需多虑，因为这其实是在java heap上创建Java对象。

####NIO

Java的nio有三种方法创建ByteBuffer：`wrap(byte[])`、`allocate(int)`、`allocateDirect(int)`，第三种方法是在堆外申请内存，在使用较大块buffer的时候，能获得较高的效率。不过这种方式申请的内存可以被GC，但是如果使用不当导致泄漏，则比较难查找。

对于Oracle的HotSpot VM，可以用`-XX:MaxDirectMemorySize`指定direct buffer的最大值，这个默认值是0，即不限制。

说句题外话，Oracle的JDK7去掉了allocateDirect所分配内存的页对齐，这样可以减小分配很多小buffer的内存消耗。


####AWT/Swing
二者的一些bug会导致堆内存泄露，对于AWT/Swing引起的堆外内存泄露，我倒没什么经验，摘一个别人发的例子：

```java
java.awt.Font font = java.awt.Font.createFont(Font.TRUETYPE_FONT, file);
font.deriveFont(Font.PLAIN, i)
```

至于哪些数据在堆外分配，读者可以阅读下源码分析下。对于这种情况，可以使用singleton模式解决。


####Inflater&Deflater

Java的zip包里两个重要类，记住一定要保证`end()`能被调用。这个可能比较常见一些，在此就不多做解释了。

```java
Inflater inflater = null;
Deflater deflater = null;
try{
	inflater = new Inflater();
   	deflater = new Deflater();
}catch(Exception e){
    ;
}finally{
    inflater.end();
	deflater.end();
}
```

以上就是四种比较常见的non-heap内存泄露原因，如果你的程序有堆外内存泄露的现象，可以着重从上述四个方面查找原因。
