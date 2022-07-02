---
bilayout: post
title: "实战Mysql Explain"
date: 2021-12-20
description: "2021-12-20-mysql-explain"
categories: Mysql
tag: [Mysql]
---

# 前言

Mysql Explain是非常重要的，在我们写完Mysql命令之后，帮我们分析Sql的性能。

其使用是十分简单的，在sql语句前面加上explain即可。

<img src="https://cdn.jsdelivr.net/gh/haojunsheng/ImageHost@master/img/20220110203026.png" alt="image-20220110203026199" style="zoom:50%;" />

# 准备

我们准备了一张表用于演示。

```mysql
create table myOrder
(
    id int auto_increment primary key,
    user_id int,
    order_id int,
    order_status tinyint,
    create_date datetime
);
create index idx_userid_order_id_createdate on myOrder(user_id,order_id,create_date);
```

# id:select子句或者操作的顺序

- id相同：执行顺序自上而下
- id不同：id值越大优先级越高，越先被执行

# select_type查询类型

查询类型是简单还是复杂的。

- simple:不需要union操作或者不包含子查询

```mysql
mysql> explain select * from myOrder where order_id=1;
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | order | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | Using where |
+----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```

- primary：需要union操作或者包含子查询

  ```mysql
  mysql> explain select (select user_id from order) from myOrder;
  +----+-------------+------------+------------+-------+---------------+--------------------------------+---------+------+------+----------+-------------+
  | id | select_type | table      | partitions | type  | possible_keys | key                            | key_len | ref  | rows | filtered | Extra       |
  +----+-------------+------------+------------+-------+---------------+--------------------------------+---------+------+------+----------+-------------+
  |  1 | PRIMARY     | order | NULL       | index | NULL          | idx_userid_order_id_createdate | 16      | NULL |    1 |   100.00 | Using index |
  |  2 | SUBQUERY    | order | NULL       | index | NULL          | idx_userid_order_id_createdate | 16      | NULL |    1 |   100.00 | Using index |
  +----+-------------+------------+------------+-------+---------------+--------------------------------+---------+------+------+----------+-------------+
  2 rows in set, 1 warning (0.00 sec)
  ```

- union：多表查询

  ```mysql
  mysql> explain select * from myOrder union select * from myOrder;
  +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
  | id | select_type  | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra           |
  +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
  |  1 | PRIMARY      | myOrder    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL            |
  |  2 | UNION        | myOrder    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL            |
  | NULL | UNION RESULT | <union1,2> | NULL       | ALL  | NULL          | NULL | NULL    | NULL | NULL |     NULL | Using temporary |
  +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
  3 rows in set, 1 warning (0.01 sec)
  ```

# table表名

前面有，不在赘述。

# partitions分区信息

# type类型

访问类型，Mysql决定如何查找表中的行。

- all：全表扫描
- index：从索引中读取
- range：只检索给定范围的行，使用一个索引来选择行，一般就是在where语句中出现了between、<、>、in等的查询
- ref：非唯一性索引扫描，返回匹配某个单独值的所有行
- System:只有一行数据或者是空表
- const：使用唯一索引或者主键
- eq_ref:唯一性索引扫描，对于每个索引键，表示只有一条记录与之匹配，常见于主键或唯一索引扫描

# possible_keys

查询中可能使用的索引。

# key

查询中实际使用的索引。

# key_len

查询的索引长度。

# ref

# rows

预估的扫描行数

# Extra

## Using filesort文件排序

额外的排序

## Using index覆盖索引

where筛选条件是索引的前导列

```mysql
mysql> explain select user_id,order_id,create_date from myOrder where user_id=1;
+----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------------+
| id | select_type | table      | partitions | type | possible_keys                  | key                            | key_len | ref   | rows | filtered | Extra       |
+----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------------+
|  1 | SIMPLE      | test_order | NULL       | ref  | idx_userid_order_id_createdate | idx_userid_order_id_createdate | 5       | const |    1 |   100.00 | Using index |
+----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```

## Using where；Using index，覆盖索引

- where筛选条件是索引列之一但是不是索引的不是前导列

  ```mysql
  mysql> explain select user_id,order_id,create_date from myOrder where order_id=1;
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  | id | select_type | table      | partitions | type  | possible_keys                  | key                            | key_len | ref  | rows | filtered | Extra                    |
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  |  1 | SIMPLE      | test_order | NULL       | index | idx_userid_order_id_createdate | idx_userid_order_id_createdate | 16      | NULL |    1 |   100.00 | Using where; Using index |
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  1 row in set, 1 warning (0.00 sec)
  ```

- where筛选条件是索引的前导列，但是是一个范围

  ```mysql
  mysql> explain select user_id,order_id,create_date from myOrder where user_id>1 and user_id<5;
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  | id | select_type | table      | partitions | type  | possible_keys                  | key                            | key_len | ref  | rows | filtered | Extra                    |
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  |  1 | SIMPLE      | test_order | NULL       | index | idx_userid_order_id_createdate | idx_userid_order_id_createdate | 16      | NULL |    1 |   100.00 | Using where; Using index |
  +----+-------------+------------+------------+-------+--------------------------------+--------------------------------+---------+------+------+----------+--------------------------+
  1 row in set, 1 warning (0.01 sec)
  ```

## Using index condition：需要回表

- Using where,查询的列未被索引覆盖,where筛选条件非索引的前导列或者是非索引列

  ```mysql
  mysql> explain select user_id,order_id,create_date,order_status from myOrder where order_id=1;
  +----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
  | id | select_type | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
  +----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
  |  1 | SIMPLE      | test_order | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | Using where |
  +----+-------------+------------+------------+------+---------------+------+---------+------+------+----------+-------------+
  1 row in set, 1 warning (0.00 sec)
  ```

- NULL,查询的列未被索引覆盖，where条件是索引的前导列

  ```sql
  mysql> explain select user_id,order_id,create_date,order_status from myOrder where user_id=1;
  +----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------+
  | id | select_type | table      | partitions | type | possible_keys                  | key                            | key_len | ref   | rows | filtered | Extra |
  +----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------+
  |  1 | SIMPLE      | test_order | NULL       | ref  | idx_userid_order_id_createdate | idx_userid_order_id_createdate | 5       | const |    1 |   100.00 | NULL  |
  +----+-------------+------------+------------+------+--------------------------------+--------------------------------+---------+-------+------+----------+-------+
  1 row in set, 1 warning (0.01 sec)
  ```

## Using temporary，表示的是需要使用临时表

这里比较复杂，可能是内存临时表，也可能是磁盘临时表。

- 内存临时表：指的是使用Memory引擎的表。
- 磁盘临时表：一般使用Innodb引擎。

# 参考

[Mysql官方文档](https://dev.mysql.com/doc/refman/5.6/en/explain-output.html)

