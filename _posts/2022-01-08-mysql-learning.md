---
layout: post
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

Java Data Base Connectivity,它是可以执行SQL语句的Java API。

为了简化编程和统一各个数据库，进行了抽象。

- 定义了连接(Connection)：用来代表和数据库的连接。
- 执行sql语句，用Stagement表示
- 返回的结果用ResultSet表示

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

了解下**PreparedStatement**对象：

- 预编译，提高效率
- 防止SQL注入

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

O/R Mapping ：Object Relational Mapping。

Java对象和Mysql的表数据映射需要我们手动操作，希望把这个过程自动化完成。

![image-20220111001208201](/Users/haojunsheng/Library/Application Support/typora-user-images/image-20220111001208201.png)

<img src="https://cdn.jsdelivr.net/gh/haojunsheng/ImageHost@master/img/20220110234831.png" alt="image-20220110234831474" style="zoom: 25%;" />

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

JPA针对这些问题，定义了一系列的规范，Hibernate和Spring Data JPA实现了JPA规范。

## Hibernate

事实上，现有的Hibernate，后有的JPA规范。

## Spring Data JPA

使用现有的JPA的实现，进行了简单的封装。

使用demo，可以看到，无需关注SQL编写。

- 配置文件，application.properties

  ```java
  spring.jpa.hibernate.ddl-auto=create-drop
  spring.jpa.properties.hibernate.show_sql=true
  spring.jpa.properties.hibernate.format_sql=true
  ```

- Coffee.java

  ```java
  @Entity
  @Table(name = "T_MENU")
  @Builder
  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public class Coffee implements Serializable {
      @Id
      @GeneratedValue
      private Long id;
      private String name;
      @Column
      @Type(type = "org.jadira.usertype.moneyandcurrency.joda.PersistentMoneyAmount",
              parameters = {@org.hibernate.annotations.Parameter(name = "currencyCode", value = "CNY")})
      private Money price;
      @Column(updatable = false)
      @CreationTimestamp
      private Date createTime;
      @UpdateTimestamp
      private Date updateTime;
  }
  ```

- CoffeeOrder.java

  ```java
  @Entity
  @Table(name = "T_ORDER")
  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  @Builder
  public class CoffeeOrder implements Serializable {
      @Id
      @GeneratedValue
      private Long id;
      private String customer;
      @ManyToMany
      @JoinTable(name = "T_ORDER_COFFEE")
      private List<Coffee> items;
      @Column(nullable = false)
      private Integer state;
      @Column(updatable = false)
      @CreationTimestamp
      private Date createTime;
      @UpdateTimestamp
      private Date updateTime;
  }
  ```

- CoffeeOrderRepository.java

  ```java
  import org.springframework.data.repository.CrudRepository;
  
  public interface CoffeeOrderRepository extends CrudRepository<CoffeeOrder, Long> {
  }
  ```

- CoffeeRepository.java

  ```java
  import org.springframework.data.repository.CrudRepository;
  
  public interface CoffeeOrderRepository extends CrudRepository<CoffeeOrder, Long> {
  }
  ```

- JpaDemoApplication.java

  ```java
  @SpringBootApplication
  @EnableJpaRepositories
  @Slf4j
  public class JpaDemoApplication implements ApplicationRunner {
  	@Autowired
  	private CoffeeRepository coffeeRepository;
  	@Autowired
  	private CoffeeOrderRepository orderRepository;
  
  	public static void main(String[] args) {
  		SpringApplication.run(JpaDemoApplication.class, args);
  	}
  
  	@Override
  	public void run(ApplicationArguments args) throws Exception {
  		initOrders();
  	}
  
  	private void initOrders() {
  		Coffee espresso = Coffee.builder().name("espresso")
  				.price(Money.of(CurrencyUnit.of("CNY"), 20.0))
  				.build();
  		coffeeRepository.save(espresso);
  		log.info("Coffee: {}", espresso);
  
  		Coffee latte = Coffee.builder().name("latte")
  				.price(Money.of(CurrencyUnit.of("CNY"), 30.0))
  				.build();
  		coffeeRepository.save(latte);
  		log.info("Coffee: {}", latte);
  
  		CoffeeOrder order = CoffeeOrder.builder()
  				.customer("Li Lei")
  				.items(Collections.singletonList(espresso))
  				.state(0)
  				.build();
  		orderRepository.save(order);
  		log.info("Order: {}", order);
  
  		order = CoffeeOrder.builder()
  				.customer("Li Lei")
  				.items(Arrays.asList(espresso, latte))
  				.state(0)
  				.build();
  		orderRepository.save(order);
  		log.info("Order: {}", order);
  	}
  }
  ```

  

## Mybatis

需要关注SQL的编写。

使用Demo：

- application.properties，配置文件

  ```java
  mybatis.type-handlers-package=geektime.spring.data.mybatisdemo.handler
  mybatis.configuration.map-underscore-to-camel-case=true
  mybatis.mapper-locations = classpath*:mapper/**/*.xml
  mybatis.type-aliases-package = 类型别名的包名
  ```

- MybatisDemoApplication,MapperScan配置扫描位置

  ```java
  @SpringBootApplication
  @Slf4j
  @MapperScan("geektime.spring.data.mybatisdemo.mapper")
  public class MybatisDemoApplication implements ApplicationRunner {
  	@Autowired
  	private CoffeeMapper coffeeMapper;
  
  	public static void main(String[] args) {
  		SpringApplication.run(MybatisDemoApplication.class, args);
  	}
  
  	@Override
  	public void run(ApplicationArguments args) throws Exception {
  		Coffee c = Coffee.builder().name("espresso")
  				.price(Money.of(CurrencyUnit.of("CNY"), 20.0)).build();
  		int count = coffeeMapper.save(c);
  		log.info("Save {} Coffee: {}", count, c);
  
  		c = Coffee.builder().name("latte")
  				.price(Money.of(CurrencyUnit.of("CNY"), 25.0)).build();
  		count = coffeeMapper.save(c);
  		log.info("Save {} Coffee: {}", count, c);
  
  		c = coffeeMapper.findById(c.getId());
  		log.info("Find Coffee: {}", c);
  	}
  }
  ```

- Mapper定义接口

  ```java
  @Mapper
  public interface CoffeeMapper {
      @Insert("insert into t_coffee (name, price, create_time, update_time)"
              + "values (#{name}, #{price}, now(), now())")
      @Options(useGeneratedKeys = true)
      int save(Coffee coffee);
  
      @Select("select * from t_coffee where id = #{id}")
      @Results({
              @Result(id = true, column = "id", property = "id"),
              @Result(column = "create_time", property = "createTime"),
              // map-underscore-to-camel-case = true 可以实现一样的效果
              // @Result(column = "update_time", property = "updateTime"),
      })
      Coffee findById(@Param("id") Long id);
  }
  ```

- Coffee.java

  ```java
  @Data
  @AllArgsConstructor
  @NoArgsConstructor
  @Builder
  public class Coffee {
      private Long id;
      private String name;
      private Money price;
      private Date createTime;
      private Date updateTime;
  }
  ```

  

### MyBatis Generator

可以看到，MyBatis需要我们关注SQL的编写。**MyBatis Generator**可以根据表帮助我们生成：

- POJO
- Mapper 接⼝
- SQL Map XML

使用：

- 命令行：java -jar mybatis-generator-core-x.x.x.jar -configfile generatorConfig.xml
- **mybatis-generator-maven-plugin**插件
  - mvn mybatis-generator:generate
  - ${basedir}/src/main/resources/generatorConfig.xml

### MyBatis PageHelper



## 数据库连接池

HikariCP，Druid。

手动实现一个数据库连接池。

# 3. Mysql进阶

## 索引那些事

[参考](https://haojunsheng.github.io/2021/11/mysql-index/)

## 锁

## 事务

## Explain

[参考](https://haojunsheng.github.io/2021/12/mysql-explain/)
