---
layout: post
title: "web项目结构"
date: 2020-06-10
description: "2020-06-10-web项目结构"
categories: web
tag: [web,spring]
---

<!--ts-->

<!-- Added by: anapodoton, at: 2020年 7月 5日 星期日 16时29分17秒 CST -->

<!--te-->

# 前言

应用分层：

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20200706234855.png" alt="image-20200706234855430" style="zoom:50%;" />

- 开放接口层:可直接封装 Service 方法暴露成 **RPC** 接口;通过 Web 封装成 http 接口;网关控制层等。
- 终端显示层:各个端的模板渲染并执行显示的层。当前主要是 velocity 渲染，JS 渲染，JSP 渲染，移动端展示等。
- Web 层:主要是对访问控制进行转发，各类基本参数校验，或者不复用的业务简单处理等。
- Service 层:相对具体的业务逻辑服务层。
- Manager 层:通用业务处理层，它有如下特征:
   1) 对第三方平台封装的层，预处理返回结果及转化异常信息。
   2) 对 Service 层通用能力的下沉，如缓存方案、中间件通用处理。 3) 与 DAO 层交互，对多个 DAO 的组合复用。
- DAO 层:数据访问层，与底层 MySQL、Oracle、Hbase、OB 等进行数据交互。
- 外部接口或第三方平台:包括其它部门 RPC 开放接口，基础平台，其它公司的 HTTP 接口。



分层领域模型规约：

- DO(Data Object):此对象与数据库表结构一一对应，通过 DAO 层向上传输数据源对象。
- DTO(Data Transfer Object):数据传输对象，Service 或 Manager 向外传输的对象。
- BO(Business Object):业务对象，可以由 Service 层输出的封装业务逻辑的对象。
- Query:数据查询对象，各层接收上层的查询请求。注意超过 2 个参数的查询封装，禁止使用 Map 类 来传输。
- VO(View Object):显示层对象，通常是 Web 向模板渲染引擎层传输的对象。



<img src="../../../../Library/Application Support/typora-user-images/image-20200707004213701.png" alt="image-20200707004213701" style="zoom:33%;" />

下面是src/main/resources/，存放静态资源。

<img src="../../../../Library/Application Support/typora-user-images/image-20200707004317265.png" alt="image-20200707004317265" style="zoom:50%;" />



<img src="../../../../Library/Application Support/typora-user-images/image-20200707004543179.png" alt="image-20200707004543179" style="zoom:50%;" />

<img src="../../../../Library/Application Support/typora-user-images/image-20200707004606199.png" alt="image-20200707004606199" style="zoom:50%;" />

