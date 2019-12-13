---
layout: post
title: "Borg,Omega,K8s之k8s的前世今生"
date: 2019-12-20
description: "2019-12-20-Borg,Omega,K8s之k8s的前世今生"
categories: docker
tag: docker
---

<!--ts-->

<!--te-->

# 前言

[Borg, Omega, and Kubernetes](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/44843.pdf) 



首先讲了Borg是第一个容器管理系统，主要干了两件事：管理长期运行的服务和批处理工作。在此之前，这两件事是由2个系统来干的，Babysister和Global Work Queue。Borg在linux的帮助下可以很好的共享资源，也可以很好的实现敏感数据的隔离。

随着越来越多的人使用，Brog提供了更加丰富的功能，配置和更新工作，预言资源，动态加入配置文件，服务发现，负载均衡，弹性收缩，生命周期管理，定额管理。其实在Google内部有多个团队在做这件事情，但是由于Brog的扩展性，健壮性得以继续存活。

Omega，是Brog的替代者，目的是为了提高软件工程的质量。保留了Brog的核心技术。但是是从头构建的。Omega将群集的状态存储在一个基于Paxos的集中式面向事务的存储中，该存储由群集控制平面的不同部分（例如调度程序）访问，并使用乐观并发控制来处理偶发的冲突。这种解耦可以让所有的配置不必通过中心化的master。

K8s是开源的系统，和Omega 相似，k8s的核心是共享存储的存储性，和Omega 不同的是，k8s仅仅通过REST来访问。更重要的是k8s是运行在集群中的，可以更加方便的部署和管理复杂的系统。

本篇文章将会介绍google从Omega到k8s的经验和教训。

# 容器

在历史的发展中，chroot 提供了根文件隔离系统，FreeBSD扩展了namespace，linux的cGroups综合了这些特点。

容器提供的资源隔离技术大大提高了我们的利用率。然后是balabala的举例。但是容器技术并不是完美的，对于操作系统的内核，是无法隔离的。

































