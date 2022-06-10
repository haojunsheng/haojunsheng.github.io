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

# 静态容器

处理静态html。html基于http协议进行传递。

比较复杂的点在于Socket。进行引发出IO模型这个复杂的事情。

# 动态容器

我们需要了解Servlet。







不可靠组件构建出可靠的系统。

- 单体系统：单台机器不可能满足请求；开发效率低；
- SOA：大型软件一体化解决方案（工业化，流水化）；极其复杂；
- 微服务：简化的SOA；
- 无服务



- 远程过程调用Remote Procedure Call，RPC
  - 最开始是为了满足进程间通信（IPC）
  - 语言级别（非系统级别）的通讯协议，允许运行于一台计算机上的程序以某种管道作为通讯媒介（即某种传输协议的网络），去调用另外一个地址空间（通常为网络上的另外一台计算机）。
  - 客观上讲，“像本地方法一样调用远程方法”是不可能的，因为通讯等成本是客观存在的。
  - 三大问题
    - 数据表示：传递给方法的参数，以及方法的返回值；由于跨语言和不同操作系统等原因需要进行序列化和反序列化；
    - 数据传递：指应用层传输协议，两个终端需要传输序列化后的数据，以及异常，安全，超时等信息；特别的，如果双方都是HTTP服务，且要求简单，则可以使用HTTP进行数据传递；
    - 方法表示：如何表示一个方法？如何找到这些方法？定义了接口描述语言（Interface Description Language，IDL）。
  - 没有完美的RPC：简单、普适和高性能三者无法同时满足；



- 事务
  - 本地事务（单服务，单数据源）
    - 数据库事务
      - 原子性、隔离性、持久性是手段，一致性是目的。
  - 全局事务（单服务，多数据源）
    - Java Transaction API，JTA
  - 共享书屋（多服务，单数据源）
  - 分布式事务（多服务，多数据源）
    - CAP理论
      - 一致性：所有副本节点的数据是没有矛盾的
        - 与数据库的ACID中的C是不一致的，分别是副本的一致性和数据库状态的一致性。
        - 最终一致性
      - 可用性
      - 分区容忍性
    - 实现
      - 可靠消息队列
      - Try-Confirm-Cancel，TCC，强业务侵入
      - SAGA事务模型：柔性事务方案，基于数据补偿代替回滚



RPC和HTTP的区别：

- RPC用于后端通讯，HTTP一般用于前后端通讯
- 本质上都是解决通讯的
- RPC解决三大问题：表示数据，传递数据，表示方法

REST和RPC的区别：

- RPC：面向过程
- REST：面向资源。性能较差。强耦合HTTP。



