[jingege.github.com](http://jingege.github.com)
==================
折腾了几天，终于把Pages整好了，现在已经兼顾了美观和功能。

先是使用[Pelican](http://blog.getpelican.com/)，功能齐全但唯一不好的是主题太丑了。放弃。

转而投向[Jekyll](http://jekyllrb.com/)，此为github官方推荐。找了个稍微好看的[UP](http://caarlos0.github.com/posts/up-a-jekyll-theme/)主题，参照[realjenius](http://realjenius.com/2012/12/01/jekyll-category-tag-paging-feeds/)的category和tag的plugin给UP也加上了对应的功能，其实就是一些模板语言，外加一些CSS上的小调整。

不过遗憾的是github pages官方不支持plugin，无奈只能放弃自动构建，采用了三个branch

* gh-pages Pages标记分支
* master 主分支，pages从此分区开始部署
* source 源码分支

现在发布起来要麻烦一些：

* 修改source分支
* 编译
* checkout到master，把编译输出的内容cp到master中
* 把master push到origin master

后续还要做一些小的调整，有兴趣可以直接fork我的主题。