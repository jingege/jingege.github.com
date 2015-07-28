---
layout: post
date: 2014-01-27 19:10:25
title: oozie的使用总结
categories: [bigdata]
tags: 
- oozie
- hive
published: true
summary: 最近在做oozie相关的工作，遇到一些问题，在此做个小结
---

本篇不是oozie的教程，官网的文档虽然比较粗糙，但已经非常全面，可直接参考，下文总结下oozie使用中遇到的一些问题（持续更新中）。

oozie版本：3.3.2

###时区问题

oozie默认使用UTC时区，而服务器上可能是CST，建议统一使用GMT+0800。

* 不要修改oozie-default.xml，无效。在oozie-site.xml中添加：

```xml
<property>
    <name>oozie.processing.timezone</name>
    <value>GMT+0800</value>
</property>
```

* 可以用`oozie info --timezones`来查看支持的时区
* 使用GMT+0800后，时间不可以再使用形如`2014-01-24T13:40Z`的格式，要使用对应的形如`2014-01-24T13:40+0800`的格式
* 还有一点比较重要，即oozie web console的TimeZone设置要和上述一致，否则你在web console中看到的时间在感官上都是不正确的

###Hive相关
oozie会启动一个MR job来启动hive client，需要在你的oozie app里自行指定hive的配置，以及提供相关lib，因为不确定是哪一台节点，所以需要给每一台计算节点都分配hive metastore的权限。

#### hive-site.xml
* 使用<job-xml>指定hive-site.xml位置，下例中对应位置为该oozie app所在的目录，也可以指定一个绝对的HDFS路径

    ```
<action name="trackinfo">
    <hive xmlns="uri:oozie:hive-action:0.2">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <job-xml>hive-site.xml</job-xml>
        <configuration>
            <property>
                <name>mapred.job.queue.name</name>
                <value>${queueName}</value>
            </property>
        </configuration>
        <script>trackinfo.hql</script>
        <param>label=${wf:actionData('date')['lastday']}</param>
    </hive>
    <ok to="end"/>
    <error to="fail"/>
</action>
    ```

####hive的lib
* 在job.properties中设置`oozie.use.system.libpath=true`
* 使用`oozie.libpath=/path/to/lib`指定lib路径

####metastore
* 切记要把metastore的相应jdbc驱动放到lib里
* 别忘了给每个计算节点授权，否则连接不上metastore

####hive action的错误如何分析？
hive action执行失败，怎么分析原因呢？在oozie的web console中，打开因出错被KILL的action节点，打开`Console URL`即可以看到对应的MR jobdetails页面，一般错误信息在Map的日志里，打开你就会发现，日志的内容涵盖了hive job的定义、hql以及控制台输出，足够分析错误原因了。

###前一天
由于我司大多数job是计算前一天的数据，故需在调度时动态计算前一天的日期字符串，使用shell action结合 <capture-output/>可以捕捉控制台输出，输出格式需为`A=B`，这样就可以使用`${wf:actionData('A')['B']}`提取所需的字符串了。

```
<action name="date">
    <shell xmlns="uri:oozie:shell-action:0.1">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <exec>${cmd}</exec>
        <argument>-d</argument>
        <argument>1day ago</argument>
        <argument>+lastday=%Y-%m-%d</argument>
        <capture-output/>
    </shell>
    <ok to="nextStep"/>
    <error to="fail"/>
</action>
```
其中cmd=/bin/date

###权限
遇到HDFS相关的权限问题，请通过修改oozie app提交用户或修改HDFS文件权限的方式自行解决。