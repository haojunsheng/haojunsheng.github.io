---
layout: post
title: "github如何支持markdown的toc"
date: 2019-12-09
description: "2019-12-09-github如何支持markdown的toc"
categories: 技巧
tag: 技巧
---

<!--ts-->

<!--te-->

# 前言

markdown算是很好的写作格式，toc标签可以让读者更好的看我们文章的大纲，并且可以快速跳转。像是下面这样:

<img src="https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191209175554.png" style="zoom:50%;" />



可是遗憾的是，不是所有的编译器都支持toc这个标签的，比如github，这样就比较烦了，像是下面这样。如果文章比较长的话，我们不能从整体上来把握。

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191209175433.png)

# 解决

对于一个程序员来讲，遇到问题，当然得解决了，为了避免重复造轮子，我先用google来搜索下。

<img src="https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191209175847.png" style="zoom:50%;" />

第一个点进去，瞅瞅，star，fork，和issue，感觉还不错，看下readme，就决定入坑了。

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191209175927.png)

地址是这个：https://github.com/ekalinin/github-markdown-toc

# 安装

可以从readme里面看到，支持Linux和mac，好像并不支持windows。

linux：

```
$ wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
$ chmod a+x gh-md-toc
```

mac:

```
$ curl https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc -o gh-md-toc
$ chmod a+x gh-md-toc
```

# 使用方法

直接翻译自readme。

## STDIN

很简单，不再赘述。

```
cat ~/projects/Dockerfile.vim/README.md | ./gh-md-toc -
  * [Dockerfile.vim](#dockerfilevim)
  * [Screenshot](#screenshot)
  * [Installation](#installation)
        * [OR using Pathogen:](#or-using-pathogen)
        * [OR using Vundle:](#or-using-vundle)
  * [License](#license)
```

## 本地文件

当然我们也可以为本地的文件来生成

```
➥ ./gh-md-toc ~/projects/Dockerfile.vim/README.md                                                                                                                                                В
Table of Contents
=================

  * [Dockerfile.vim](#dockerfilevim)
  * [Screenshot](#screenshot)
  * [Installation](#installation)
        * [OR using Pathogen:](#or-using-pathogen)
        * [OR using Vundle:](#or-using-vundle)
  * [License](#license)
```

然后把生成的这一堆

## 远程文件

当然我们也可以为远程文件生成toc，当然我们需要手动把生成的toc放到远程文件。

```
./gh-md-toc https://github.com/ekalinin/envirius/blob/master/README.md

Table of Contents
=================

  * [envirius](#envirius)
    * [Idea](#idea)
    * [Features](#features)
  * [Installation](#installation)
  * [Uninstallation](#uninstallation)
  * [Available plugins](#available-plugins)
  * [Usage](#usage)
    * [Check available plugins](#check-available-plugins)
    * [Check available versions for each plugin](#check-available-versions-for-each-plugin)
    * [Create an environment](#create-an-environment)
    * [Activate/deactivate environment](#activatedeactivate-environment)
      * [Activating in a new shell](#activating-in-a-new-shell)
      * [Activating in the same shell](#activating-in-the-same-shell)
    * [Get list of environments](#get-list-of-environments)
    * [Get current activated environment](#get-current-activated-environment)
    * [Do something in environment without enabling it](#do-something-in-environment-without-enabling-it)
    * [Get help](#get-help)
    * [Get help for a command](#get-help-for-a-command)
  * [How to add a plugin?](#how-to-add-a-plugin)
    * [Mandatory elements](#mandatory-elements)
      * [plug_list_versions](#plug_list_versions)
      * [plug_url_for_download](#plug_url_for_download)
      * [plug_build](#plug_build)
    * [Optional elements](#optional-elements)
      * [Variables](#variables)
      * [Functions](#functions)
    * [Examples](#examples)
  * [Example of the usage](#example-of-the-usage)
  * [Dependencies](#dependencies)
  * [Supported OS](#supported-os)
  * [Tests](#tests)
  * [Version History](#version-history)
  * [License](#license)
  * [README in another language](#readme-in-another-language)
```

## 多个文件

支持多个文件：

```
➥ ./gh-md-toc \
    https://github.com/aminb/rust-for-c/blob/master/hello_world/README.md \
    https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md \
    https://github.com/aminb/rust-for-c/blob/master/primitive_types_and_operators/README.md \
    https://github.com/aminb/rust-for-c/blob/master/unique_pointers/README.md

  * [Hello world](https://github.com/aminb/rust-for-c/blob/master/hello_world/README.md#hello-world)

  * [Control Flow](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#control-flow)
    * [If](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#if)
    * [Loops](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#loops)
    * [For loops](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#for-loops)
    * [Switch/Match](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#switchmatch)
    * [Method call](https://github.com/aminb/rust-for-c/blob/master/control_flow/README.md#method-call)

  * [Primitive Types and Operators](https://github.com/aminb/rust-for-c/blob/master/primitive_types_and_operators/README.md#primitive-types-and-operators)

  * [Unique Pointers](https://github.com/aminb/rust-for-c/blob/master/unique_pointers/README.md#unique-pointers)
```

## 合并文件

You can easily combine both ways:

```
➥ ./gh-md-toc \
    ~/projects/Dockerfile.vim/README.md \
    https://github.com/ekalinin/sitemap.s/blob/master/README.md

  * [Dockerfile.vim](~/projects/Dockerfile.vim/README.md#dockerfilevim)
  * [Screenshot](~/projects/Dockerfile.vim/README.md#screenshot)
  * [Installation](~/projects/Dockerfile.vim/README.md#installation)
        * [OR using Pathogen:](~/projects/Dockerfile.vim/README.md#or-using-pathogen)
        * [OR using Vundle:](~/projects/Dockerfile.vim/README.md#or-using-vundle)
  * [License](~/projects/Dockerfile.vim/README.md#license)

  * [sitemap.js](https://github.com/ekalinin/sitemap.js/blob/master/README.md#sitemapjs)
    * [Installation](https://github.com/ekalinin/sitemap.js/blob/master/README.md#installation)
    * [Usage](https://github.com/ekalinin/sitemap.js/blob/master/README.md#usage)
    * [License](https://github.com/ekalinin/sitemap.js/blob/master/README.md#license)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)
```

## 自动插入和更新toc

首先在文件中添加下面2行：

```
<!--ts-->
<!--te-->
```

然后：

```
$ ./gh-md-toc --insert README.test.md

Table of Contents
=================

   * [gh-md-toc](#gh-md-toc)
   * [Installation](#installation)
   * [Usage](#usage)
      * [STDIN](#stdin)
      * [Local files](#local-files)
      * [Remote files](#remote-files)
      * [Multiple files](#multiple-files)
      * [Combo](#combo)
   * [Tests](#tests)
   * [Dependency](#dependency)

!! TOC was added into: 'README.test.md'
!! Origin version of the file: 'README.test.md.orig.2018-02-04_192655'
!! TOC added into a separate file: 'README.test.md.toc.2018-02-04_192655'


Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)
```

当文件更新的时候，直接重复就行了，也很简单。

# 总结

看了下，生成的代码，发现本质上是在文件的开头为每一个\#添加[example](#example)来实现的。我们完全可以自己来实现一个。

另外由于我经常使用这个命令，所以我把这个文件移动到了/usr/local/bin/下，并且改名为md-toc，也经常使用insert这个，所以我直接配置了别名，像是这样：

```
mv gh-md-toc /usr/local/bin/md-toc
alias md-toc="/usr/local/bin/md-toc --insert"
```

以后，我直接这样就可以了：

md-toc README.md

当然记得在README.md里添加。