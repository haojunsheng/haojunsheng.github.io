---
bilayout: post
title: "mysql学习之路"
date: 2022-01-08
description: "2022-01-08-mysql-learning"
categories: Mysql
tag: [Mysql]
---

# 前言

Mysql作为软件开发工程师的必备技能，本人在学习Mysql的过程中遇到了非常多的坑，现在将学习的过程进行记录。

# 1. 初学Mysql

这里推荐极客时间的《SQL 必知必会》课程。

我基于这个专栏，做了[学习笔记](https://github.com/haojunsheng/JavaDeveloper/blob/master/geekbang/mysql/mysql-must-konw-chenyng.md)，有忘记的语法的话，我会回到这里看下。

# 2. Java & Mysql

## Socket

最早是基于Socket编程来实现的。但是Java和Mysql，Oracle等的规范都不相同。

## JDBC

为了简化编程和统一各个数据库，进行了抽象。

- 定义了连接(Connection)：用来代表和数据库的连接。
- 执行sql语句，用Stagement表示
- 返回的结果用Result表示

```java
public class JDBCTest {

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.jdbc.driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        String url = "jdbc:mysql://127.0.0.1:3306/stu_db/";
        // 获取数据库连接
        Connection connection = null;
        // 获取语句
        Statement statement = null;
        //  执行结果
        ResultSet resultSet = null;
        try {
            connection = DriverManager.getConnection(url, "username", "password");
            statement = connection.createStatement();
            resultSet = statement.executeQuery("select * from users");
            while (resultSet.next()) {
                resultSet.getInt("id");
                resultSet.getString("name");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (resultSet != null) {
                    resultSet.close();
                }
                if (statement != null) {
                    statement.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (SQLException e) {

            }
        }
    }

}
```

## JDBCTemplate

上面的那坨代码写着太恶心人了。本质上，数据库访问的操作为：

- **指定数据库连接参数**
- 打开数据库连接
- **声明SQL语句**
- 预编译并执行SQL语句
- 遍历查询结果
- **处理每一次遍历操作**
- 处理抛出的任何异常
- 处理事务
- 关闭数据库连接

```java
DataSource dataSource = new MysqlDataSource();
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        List<User> users = jdbcTemplate.query("select * from users", new RowMapper<User>() {
            @Override
            public User mapRow(ResultSet rs, int rowNum) throws SQLException {
                User user = new User();
                user.setName(rs.getString("name"));
                user.setAge(rs.getInt("age"));
                return user;
            }
        });
```

并且可以结合Spring进行使用。

## O/R Mapping

O/R Mapping ：Object Relational Mapping

Java对象和Mysql的表数据映射需要我们手动操作，希望把这个过程自动化完成。

## JPA

Java Persistence API。

基本的原则：

- 数据库的表和Java的类进行映射
- 表中的行记录和Java对象进行映射
- 表中的列和Java的属性进行映射

涉及到细节

- 很多情况下，多个类合到一起才可以和一张表进行映射，如

  ```
  public class User {
  
      private Name name;
      private int id;
  }
  
  
  public class Name {
  
      private String firstName;
      private String middleName;
      private String lastName;
  }
  
  create table User (
      id int not null ,
      firstName VARCHAR ,
      middleName VARCHAR ,
      lastName VARCHAR 
  )
  ```

- Java的类之间有继承关系，Mysql没有

- 对象的标识问题

  - Java用a.equals(b)来判断对象是否相等，数据库使用外键

- 对象的关联问题

- 数据导航

  - City c = user.getAddress().getCity(); 数据库只能通过表的连接来实现

- 对象的状态

JPA针对这些问题，定义了一系列的规范，Hibernate实现了JPA规范。

## Hibernate



## Mybatis



## 数据库连接池



# 3. Mysql进阶

## 索引那些事

## 锁

## 事务

## Explain

