---
layout: post
date: 2013-10-03 19:15:00
title: '[翻译]Clojure Libs and Namespaces: require, use, import, and ns'
categories: [programming]
tags: 
- clojure
published: false
summary: 翻译了一篇关于clojure编程中的库和命名空间的文章
---

原文：http://blog.8thlight.com/colin-jones/2010/12/05/clojure-libs-and-namespaces-require-use-import-and-ns.html

>每当我给一个clojure新手讲解如何引用其他命名空间时，我自己都觉得这有点复杂和困惑。

现在我不会再花时间吐槽当前的namespaces设计了（参阅[this Clojure mailing list discussion](http://groups.google.com/group/clojure-dev/browse_thread/thread/46559fd9eb127bdd) and [the design discussion around namespaces in the Clojure Confluence](http://dev.clojure.org/display/design/Loading,+Compiling,+and+Namespaces)），但我觉得这里概括下Clojure lib的各种调用方式还是挺有用的。

先打开Clojure的REPL where we’ll outline the baseline commands to pull in libs，如果你不会，[下载Clojure](http://clojure.org/downloads)，参考[这篇文章](http://clojure.org/getting_started)来让REPL运行起来，如果你已经有了clojure的jar包，那么直接通过`java -jar clojure-VERSION-HERE.jar`来启动REPL。

然后我们先看下更惯用的ns宏，这个在实际的Clojure工程中比较常用。然而在REPL里，require、use和import会更常用些。and because those are used behind the scenes, we’ll start there.

####最基本的require

如果我们想使用Clojure的内建字符串操作函数，那么在clojure1.2里有一个叫做clojure.string的库，包含了像split、join和capitalize等比较有用的函数。

我们用split来分割CSV文件的第一行：

`
user=> (clojure.string/split "name,address,city,state,zip,email,phone" #",")
java.lang.ClassNotFoundException: clojure.string (NO_SOURCE_FILE:0)
`

呃，我们忘了告诉Clojure使用那个namespace了。在REPL启动的时候，有几个namespace会自动被require进来（clojure.core, clojure.set等等），但不包括clojure.string。所以要事先告诉REPL使用这个namespace。

user=> (require 'clojure.string)
nil
user=> (clojure.string/split "name,address,city,state,zip,email,phone" #",")
["name" "address" "city" "state" "zip" "email" "phone"]

可以了！让我们再仔细看下，最基本的引入其他clojure代码的require语法，其实只是一个可以带几种不同参数的Clojure函数。

首先，我们可以传入一个引用符号（quoted symbol），require会使对应的namespace可以使用完整的namespace/var-name语法来访问。我们也可以传入多个引用符号。

1 user=> (require 'clojure.string 'clojure.test)
 2 nil
 3 user=> (clojure.string/join " " ["name" "address" "city" "state" "zip" "email" "phone"])
 4 "name address city state zip email phone"
 5 user=> (clojure.test/is (= 1 2))
 6 
 7 FAIL in clojure.lang.PersistentList$EmptyList@1 (NO_SOURCE_FILE:10)
 8 expected: (= 1 2)
 9   actual: (not (= 1 2))
10 false

注意我这里为了演示第一次加载一个库的时候会发生什么，每个例子都会启动一个新的REPL。一般来讲，你第二次require一个库的时候，什么都不会发生。

待会会看到一个解决办法（主要针对交互式开发），但现在，做例子的时候还是老老实实启动一个新的REPL吧。

值得注意的是，库的名字是和它的目录结构平行的。也就是说，如果要引用clojure.string包，在你的classpath里需要有一个clojure目录，并且有一个叫string.clj的文件在clojure目录里。

Clojure的jar里是这么做的，不过在写自己的代码且有可能被外部引用的时候一定要记住这点。

当require一个namespace时，可以为其取个别名，这样就可以引用string命名空间，而不是clojure.string了，二者效果是一样的：

1 user=> (require '[clojure.string :as string])
2 nil
3 user=> (string/capitalize "foo")
4 "Foo"

这个看起来比较奇怪的引用向量的写法，是用来避免对每个符号都quote的简写形式。你也可以这么写：

1 (require ['clojure.string :as 'string])

引用多个命名空间也是一样的概念：require接收任意数量的库名作为参数，可以是引用符号的形式，也可以是上述引用向量的形式。你也可以把两种形式混合起来用。

1 user=> (require 'clojure.string '[clojure.test :as test])
2 nil
3 user=> (test/is (= 1 1))
4 true

最后看一个使用require引用多个有着相同包名前缀的库时的写法：

1 user=> (require '(clojure string test))
2 nil

这里clojure是我们想引入的库的共同前缀，所以我们只要输入一个clojure。string和test在这里就是库名，这里也可以用:as选项：

1 user=> (require '(clojure [string :as string] test))
2 nil
3 user=> (string/join [1 2 3])
4 "123"

现在，列表和向量标记的变化（即圆括号和方括号），估计都快让你抓狂了。

别怕，这里只要记住库名可以是引用符号，也可以是引用向量。当你想使用:as时，它应该是个向量，就可以了。

我们后面会看到列表是比较惯用的写法，但这并不是强制的。从语义上看，两种写法都有各自适用的场景。

Phil Hagelberg对此有些值得注意的[建议](http://p.hagelb.org/import-indent.html)，
