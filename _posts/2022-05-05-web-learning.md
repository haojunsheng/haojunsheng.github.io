---
layout: post
title: "一文学习web"
date: 2022-05-05
description: "2022-05-05-web-learning"
categories: Java
tag: [Java]
---

# 前言

- 静态容器（HTTP容器）：Apache，Nginx，处理静态html。

  - 抽象了Socket网络编程。

- 动态容器：Tomcat，是Servlet规范的实现，比如可以处理jsp

  - 对于每个Http请求，都需要相应的业务类进行处理。

  - 为了不耦合业务，使用了面向接口编程，定义了Servlet接口，业务类实现Servlet接口即可。

  - 特定的请求路由到哪个Servlet呢？于是实现了Servlet容器Tomcat

    ![img](https://static001.geekbang.org/resource/image/df/01/dfe304d3336f29d833b97f2cfe8d7801.jpg)

- Spring：

  - Spring core：管理对象的生命周期
  - Spring mvc：管理controller对象生命周期（controller本质上也是Servlet）



![img](https://static001.geekbang.org/resource/image/be/96/be22494588ca4f79358347468cd62496.jpg)

![img](https://static001.geekbang.org/resource/image/12/9b/12ad9ddc3ff73e0aacf2276bcfafae9b.png)
