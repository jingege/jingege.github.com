---
layout: post
date: 2013-09-25 21:32:16
title: Only support xterm terminal
categories: [programming]
tags:
- linux
published: true
summary: 遇到一个ssh登陆的问题
---

前几天用我的Mac版iTerm2登陆服务器时terminal报出错误：

```bash
Error: only support xterm terminal
```

我看网上有人建议使用[这个方案](http://baniu.me/2013/01/mac-ssh%E5%87%BA%E7%8E%B0error-only-support-xterm-terminal%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/)，其实是没找到病根。根据错误提示，我们应该用xterm类型的terminal登陆，所以正确的方案有二：

* 设置环境变量`export TERM=xterm`

* 修改你的ssh客户端的profile，设置terminal type为xterm

上述方式在我的iTerm2和Terminal都通过。
