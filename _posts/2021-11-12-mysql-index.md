---
layout: post
title: "mysql索引那些事"
date: 2021-11-12
description: "2021-11-12-mysql-index"
categories: Mysql
tag: [Mysql]
---

# 前言

索引是Mysql中的最为核心的概念之一。

# 核心概念

- 什么是索引？
  - 索引是为了加速对表中数据行的检索而创建的一种分散存储的数据结构
- 为什么要索引？索引的核心是减少查找的IO次数
  - 索引能极大的减少存储引擎需要扫描的数据量
  - 索引可以把随机IO变成顺序IO
  - 索引可以帮助我们在进行分组、排序等操作时，避免使用临时表

## 索引划分

- 存储类型
  - 主键索引（聚簇索引/聚集索引)，PRIMARY KEY
  - 二级索引（非聚集索引），SECONDARY KEY，需要回表

- 功能划分
  - 唯一索引：unique key
  - 联合索引
  - 全文索引

# 数据结构

为什么选择B+树？

<img src="https://cdn.jsdelivr.net/gh/haojunsheng/ImageHost@master/img/20220110202321.png" alt="image-20220110202321153" style="zoom:50%;" />

# 索引优化

- 使用区分度高的字段
  - good case: 更新时间
  - bad case：性别
- 尽量使用字段长度小的列作为索引
  - good case: 姓名
  - bad case：身份证号
- 使用Not Null的列（非空的列可以可以用0或者空串来代替）
- 最左匹配，如联合索引(a,b,c)
  - 如果不是按照索引的最左列开始查找，则无法使用索引，如select \* from t where b = ? and c = ?
  - 不能跳过索引中的列，否则只能⽤用到索引前面的部分，如select \* from t where a = ? and c = ?
  - 如果查询中有某个列的范围查询，则其右边所有的列都无法用到索引优化,如select \* from t where a > ? and c = ?
  - 不要使用%进行前缀模糊查询，如like "%name"
- 禁止select *
- 避免索引失效
  - 隐私转换，如select \* from t where a = "2",假设a是整形
  - 避免在索引字段上进行运算，如select \* from t where a -1= 2

# 参考

[深入浅出索引（上）](https://time.geekbang.org/column/article/69236)

[深入浅出索引（下）](https://time.geekbang.org/column/article/69636)

[普通索引和唯一索引，应该怎么选择？](https://time.geekbang.org/column/article/70848)

[MySQL为什么有时候会选错索引？](https://time.geekbang.org/column/article/71173)

[怎么给字符串字段加索引？](https://time.geekbang.org/column/article/71492)
