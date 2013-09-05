---
layout: post
date: 2013-03-29 15:50:45
title: Hi,Pages
categories: [life]
tags: [life]
published: true
summary: 折腾了一阵子，我的Github Pages终于可以见人了！
---

####缘起

自我的个人域名因为忘记续费被美帝可耻地抢注后，便再没心情维护我的博客，甚至最后Linode的每月19刀也竟然感觉是个累赘。

某次在有为同学感慨入职alipay之初的林林总总之后，聊起来是否该重新维护一个博客以记录成长之点滴，于是两人各自去寻安家之所。他去了[`oschina`](http://www.oschina.net)，我对国内的网络服务一直是实在不放心，便决定好好琢磨下Github Pages。

从Page Generation到`Pelican`，再到`Jekyll`。总算让我把这个博客整得有点样子了。最初使用Pelican是看到有博文写了使用说明，试了下也甚是简单，而且功能俱全，自带category、tag等功能，但无奈实在找不到合适的主题，终于放弃。

于是转投Jekyll旗下，不过Jekyll要实现category/tag的功能，是要借助第三方插件，但github官方出于安全考虑，居然把Jekyll的插件机制禁用了，无奈只能选择禁用pages的自动编译功能，这是后话。

####主题
一个好的博客，首先主题要说得过去，我最终fork了caarlos0的[UP](http://caarlos0.github.com/posts/up-a-jekyll-theme/)主题，主要是因为它实在是太简洁了，比较容易个性化定制。实际上我只对主题本身做了少许的几处调整。

####Sharing
UP主题只有Twitter的分享按钮，我用JiaThis的分享服务给替换掉了。

####Commenting
绝大多数类似Pages的静态网页服务，其评论功能都使用了[Disqus](http://disqus.com/)的Commenting服务，不过某日在微博看到新秀[`moot`](http://moot.it)之后，便决定拿moot替换掉Disqus。moot的slogan是`Forums and commenting re-imagined`，听起来煞是令人耳目一新，实际注册了用来，也确实是比较大的创新，其Path风格的api设计得很精巧。但其门槛很低，看一遍文档我就把moot装备上了。最难的地方应该是要用插件把post的file name取出来，作为comment的path的key部分，这让我学会了写Jekyll插件。

####Code highlight
作为技术博客，代码高亮肯定是必不可少的了，个人认为使用gist会很好，但最终还是选择内置的[`Pygments`](http://pygments.org/)支持。

首先是安装：

{% highlight bash %}
$ pip install Pygments
{% endhighlight %}

其次要创建相关css文件，这个新手往往会忽略：

{% highlight bash %}
$ cd path/to/jekyll/project/folder
$ pygmentize -S default -f html > css/pygments.css
{% endhighlight %}

其中default是指样式名，可以用如下方式查看有哪些样式：

{% highlight python %}
>>> from pygments.styles import STYLE_MAP
>>> STYLE_MAP.keys()
['monokai', 'manni', 'rrt', 'perldoc', 'borland', 'colorful', 'default', 'murphy', 'vs', 'trac', 'tango', 'fruity', 'autumn', 'bw', 'emacs', 'vim', 'pastie', 'friendly', 'native']
{% endhighlight %}

最后只要把css文件引入，用liquid嵌入代码即可：

<code>
&#123;% highlight java %}
code goes here~
&#123;% endhighlight %}
</code>

####Category & Tag
这是博客必不可少的功能了，但Jekyll只能通过插件来实现，我不懂Ruby，所以只能fork去了。参照[realjenius](http://realjenius.com/2012/12/01/jekyll-category-tag-paging-feeds/)的代码，把category和tag页面生成。但比较麻烦的是修改UP的主题，把category和tag链接加进来，整个过程就是在写Liquid模板，很简单。

但是使用插件，也就意味着无法让github自动编译发布博客，必须在本地把`md`处理成`html`，然后push到github才能发布。所以我最终采用了三个git分支：

- master分支，用来存放生成后的文件（默认在`_site`目录下），注意要加.nojekyll文件来禁止Pages的自动发布

- gh-pages分支，仅仅是Github Pages的必须的标记分支

- source分支，存放整站源码

发布的步骤大概是先在source分支下编写并push到origin:source，然后编译到`_site`下，切换到master分支，把`_site`下的文件覆盖过来，commit、push一路过来即可。

####结束
即便是这篇文章，也拖了好久。希望自己这次能在这个琐事缠身的年纪，坚持把这个博客维护下去。本文并未详细讲解使用Jekyll搭建Pages的过程，喜欢我这个主题的，可以`fork`我的代码。如果有其他疑问，也可以直接联系我。