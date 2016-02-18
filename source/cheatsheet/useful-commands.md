title: 一些有用的命令
date: 2015-07-30 01:06:57
---

### Java
* 获取JVM进程的heap dump
  `jmap -dump:format=b,file=/root/heap.bin 13951`

### MongoDB
* 在MongoDB里创建Capped Collection
  `db.createCollection("c",{capped:true,size:150000000})`

### Git
* 拉取远程分支
  `git checkout -b local-branchname origin/remote_branchname`
