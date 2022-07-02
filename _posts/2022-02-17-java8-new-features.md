---
layout: post
title: "Java8新特性"
date: 2022-02-17
description: "2022-02-17-java-new-features"
categories: Java
tag: [Java]
---

# 前言

Java8发布于2014年，其引入的新特性极其深远。

# Lambda表达式

## 为什么要使用Lambda表达式

lambda表达式源自函数式编程的需要。函数式编程简单来讲是对行为的抽象：把函数可以当做参数传递给另外一个函数，函数也可以作为另外一个函数的返回值。

```python
// 非函数式，不是pure funciton，有状态
int cnt;
void increment(){
    cnt++;
}
// 函数式
def inc(x):
    def incx(y):
        return x+y
    return incx

inc2 = inc(2)
inc5 = inc(5)

print inc2(5) # 输出 7
print inc5(5) # 输出 10
```

但是在Java中，函数的参数只能是类型，因此可以使用匿名类来实现函数式编程。

```java
new Thread(new Runnable(){
    @Override
    public void run(){
        System.out.println("hello1");
    }
}).start();
```

匿名类虽然没有类名，但是需要给出方法定义，还是过于繁琐。Java8中引入了lambda来进一步简化编程。

```java
new Thread(() -> System.out.println("hello2")).start();
```

## 什么是Lambda表达式

 Lambda 这个词起源于学术界开发出的一套用来描述计算的 λ 演算法，任何数据结构都可以被函数取代。

<img src="https://static001.geekbang.org/resource/image/7f/cd/7fac133e887bb91f6619887e6a6dcfcd.png?wh=1330*997" style="zoom:25%;" />

lambda表达式的基本结构如下：

```
(argument-list) -> {body}  
```

- 参数列表:可以空，也可以非空。
- 箭头
- 方法体：

```java
() -> System.out.println("Hello Lambda");
s-> s.toUpperCase();
(x,y) -> x +y ; 
```

## Lambda表达式是怎么实现的？

那么，Lambda表达式如何匹配Java的类型系统呢？答案就是，函数式接口。

函数式接口是一种只有单一抽象方法的接口，使用@FunctionalInterface来描述，可以隐式地转换成 Lambda 表达式。使用Lambda表达式来实现函数式接口，不需要提供类名和方法定义，通过一行代码提供函数式接口的实例，就可以让函数成为程序中的头等公民，**可以像普通数据一样作为参数传递，而不是作为一个固定的类中的固定方法。**

函数式接口定义在java.util.function包下，常见的几个函数式接口如下：

```java
// 1. Function函数接口： 传入一个类型为T的参数， 返回一个类型为R 的参数
public interface Function<T,R>{
    R apply(T t);
    ......
}
s -> s.length()
  
// 2. Predicate<T> 函数接口：传入一个类型为Ｔ的参数，　返回boolean
public interface Predicate<T> {
    boolean test(T t);
    ......
}
Predicate positiveNumber = i -> i > 0;
Predicate evenNumber = i -> i % 2 == 0;
assertTrue(positiveNumber.and(evenNumber).test(2));
  
// 3. Consumer<T>函数接口：传入一个类型为T的参数，没有返回值
public interface Consumer<T> {
    void accept(T t);
    ......
}
s ->  System.out.println(s)
  
// 4. Supplier<T>接口，返回一个类型为T的参数
public interface Supplier<T> {
    T get();
} 
Supplier stringSupplier = ()->"OK";
Supplier supplier = String::new;
```

除了函数式接口，Lambda表达式还包含方法引用。

### 方法引用

让Lambda表达式更加易读。

```java
// 静态方法
ContainingClass::staticMethodName
// 实例方法
containingObject::instanceMethodName
// 构造方法
ClassName::new  
```

### 默认方法

接口中增加实现，在此之前，接口中是不能进行实现的。

```java
interface Sayable{  
    // Default method   
    default void say(){  
        System.out.println("Hello, this is default method");  
    }  
    // Abstract method  
    void sayMore(String msg);  
}  
public class DefaultMethods implements Sayable{  
    public void sayMore(String msg){        // implementing abstract method   
        System.out.println(msg);  
    }  
    public static void main(String[] args) {  
        DefaultMethods dm = new DefaultMethods();  
        dm.say();   // calling default method  
        dm.sayMore("Work is worship");  // calling abstract method  
  
    }  
}  
```

# Optional可空类型

用来解决空指针异常。

```java
@Test(expected = IllegalArgumentException.class)
public void optional() {
    //通过get方法获取Optional中的实际值
    assertThat(Optional.of(1).get(), is(1));
    //通过ofNullable来初始化一个null，通过orElse方法实现Optional中无数据的时候返回一个默认值
    assertThat(Optional.ofNullable(null).orElse("A"), is("A"));
    //OptionalDouble是基本类型double的Optional对象，isPresent判断有无数据
    assertFalse(OptionalDouble.empty().isPresent());
    //通过map方法可以对Optional对象进行级联转换，不会出现空指针，转换后还是一个Optional
    assertThat(Optional.of(1).map(Math::incrementExact).get(), is(2));
    //通过filter实现Optional中数据的过滤，得到一个Optional，然后级联使用orElse提供默认值
    assertThat(Optional.of(1).filter(integer -> integer % 2 == 0).orElse(null), is(nullValue()));
    //通过orElseThrow实现无数据时抛出异常
    Optional.empty().orElseThrow(IllegalArgumentException::new);
}
```

常见用法如下：

<img src="https://static001.geekbang.org/resource/image/c8/52/c8a901bb16b9fca07ae0fc8bb222b252.jpg" alt="img" style="zoom: 25%;" />

# Stream流式计算

Java引入了Stream来实现延迟计算（惰性求值的功能）。

```java
public class EvenNumber implements Supplier<Long>{
    long num = 0;
    @Override
    public Long get() {
        num += 2;
        return num;
    }    
}
// numbers代表无穷无尽的偶数序列，只是没有计算出来而已
Stream<Long> numbers = Stream.generate(new EvenNumber());
numbers.limit(5).forEach(x->System.out.println(x));
输出： 2 4 6 8 10
```

Stream可以简化集合操作。

集合中的流式处理：

```java
Arrays.asList("Hello", "Java8", "Java7").stream()
                .map(s -> s.toUpperCase())
                .filter(s -> s.startsWith("J"))
                .forEach(s -> System.out.println(s));
// 输出
JAVA8
JAVA7

Arrays.asList("Hello", "Java8", "Java7").stream()
                .map(s -> {
                    System.out.println("map: " + s);
                    return s.toUpperCase();
                })
                .filter(s -> {
                    System.out.println("filter:" + s);
                    return s.startsWith("J");
                })
                .forEach(s -> System.out.println(s));
// 输出
map: Hello
filter:HELLO
map: Java8
filter:JAVA8
JAVA8
map: Java7
filter:JAVA7
JAVA7
```

## 创建流

- 通过stream方法把List或数组转换为流；
- 通过Stream.of方法直接传入多个元素构成一个流；
- 通过Stream.iterate方法使用迭代的方式构造一个无限流，然后使用limit限制流元素个数；
- 通过Stream.generate方法从外部传入一个提供元素的Supplier来构造无限流，然后使用limit限制流元素个数；
- 通过IntStream或DoubleStream构造基本类型的流。

```java
//通过stream方法把List或数组转换为流
@Test
public void stream()
{
    Arrays.asList("a1", "a2", "a3").stream().forEach(System.out::println);
    Arrays.stream(new int[]{1, 2, 3}).forEach(System.out::println);
}

//通过Stream.of方法直接传入多个元素构成一个流
@Test
public void of()
{
    String[] arr = {"a", "b", "c"};
    Stream.of(arr).forEach(System.out::println);
    Stream.of("a", "b", "c").forEach(System.out::println);
    Stream.of(1, 2, "a").map(item -> item.getClass().getName()).forEach(System.out::println);
}

//通过Stream.iterate方法使用迭代的方式构造一个无限流，然后使用limit限制流元素个数
@Test
public void iterate()
{
    Stream.iterate(2, item -> item * 2).limit(10).forEach(System.out::println);//2,4,8,16,32
}

//通过Stream.generate方法从外部传入一个提供元素的Supplier来构造无限流，然后使用limit限制流元素个数
@Test
public void generate()
{
    Stream.generate(() -> "test").limit(3).forEach(System.out::println);
    Stream.generate(Math::random).limit(10).forEach(System.out::println);
}

//通过IntStream或DoubleStream构造基本类型的流
@Test
public void primitive()
{
    //演示IntStream和DoubleStream
    IntStream.range(1, 3).forEach(System.out::println);
    IntStream.range(0, 3).mapToObj(i -> "x").forEach(System.out::println);

    IntStream.rangeClosed(1, 3).forEach(System.out::println);
    DoubleStream.of(1.1, 2.2, 3.3).forEach(System.out::println);

    //各种转换，后面注释代表了输出结果
    System.out.println(IntStream.of(1, 2).toArray().getClass()); //class [I
    System.out.println(Stream.of(1, 2).mapToInt(Integer::intValue).toArray().getClass()); //class [I
    System.out.println(IntStream.of(1, 2).boxed().toArray().getClass()); //class [Ljava.lang.Object;
    System.out.println(IntStream.of(1, 2).asDoubleStream().toArray().getClass()); //class [D
    System.out.println(IntStream.of(1, 2).asLongStream().toArray().getClass()); //class [J

    //注意基本类型流和装箱后的流的区别
    Arrays.asList("a", "b", "c").stream()   // Stream
            .mapToInt(String::length)       // IntStream
            .asLongStream()                 // LongStream
            .mapToDouble(x -> x / 10.0)     // DoubleStream
            .boxed()                        // Stream
            .mapToLong(x -> 1L)             // LongStream
            .mapToObj(x -> "")              // Stream
            .collect(Collectors.toList());
}
```

## filter过滤

类似SQL中的where。

```java
/最近半年的金额大于40的订单
orders.stream()
        .filter(Objects::nonNull) //过滤null值
        .filter(order -> order.getPlacedAt().isAfter(LocalDateTime.now().minusMonths(6))) //最近半年的订单
        .filter(order -> order.getTotalPrice() > 40) //金额大于40的订单
        .forEach(System.out::println);	
```

## map转换

类似SQL中的select。

```java
//计算所有订单商品数量
//通过两次遍历实现
LongAdder longAdder = new LongAdder();
orders.stream().forEach(order ->
        order.getOrderItemList().forEach(orderItem -> longAdder.add(orderItem.getProductQuantity())));

//使用两次mapToLong+sum方法实现
assertThat(longAdder.longValue(), is(orders.stream().mapToLong(order ->
        order.getOrderItemList().stream()
                .mapToLong(OrderItem::getProductQuantity).sum()).sum()));
```

## flatMap扁平化

## sorted排序

类似SQL中的order by。

```java
//大于50的订单,按照订单价格倒序前5
orders.stream().filter(order -> order.getTotalPrice() > 50)
        .sorted(comparing(Order::getTotalPrice).reversed())
        .limit(5)
        .forEach(System.out::println);	
```

## distinct去重

## skip & limit

```
//按照下单时间排序，查询前2个订单的顾客姓名和下单时间
orders.stream()
        .sorted(comparing(Order::getPlacedAt))
        .map(order -> order.getCustomerName() + "@" + order.getPlacedAt())
        .limit(2).forEach(System.out::println);
//按照下单时间排序，查询第3和第4个订单的顾客姓名和下单时间
orders.stream()
        .sorted(comparing(Order::getPlacedAt))
        .map(order -> order.getCustomerName() + "@" + order.getPlacedAt())
        .skip(2).limit(2).forEach(System.out::println);
```

## collect终结

在Stream操作中，collect是最复杂的终结操作，比较简单的终结操作还有forEach、toArray、min、max、count、anyMatch等。

## groupBy分组

## partitionBy分区

partitioningBy用于分区，分区是特殊的分组，只有true和false两组。

```java
//根据是否有下单记录进行分区
System.out.println(Customer.getData().stream().collect(
        partitioningBy(customer -> orders.stream().mapToLong(Order::getCustomerId)
                .anyMatch(id -> id == customer.getId()))));
```

## 总结

如何看中间结果：

1. 使用peek

```java
List firstPeek = new ArrayList<>();
List secondPeek = new ArrayList<>();
List result = IntStream.rangeClosed(1, 10)
        .boxed()
        .peek(i -> firstPeek.add(i))
        .filter(i -> i > 5)
        .peek(i -> secondPeek.add(i))
        .filter(i -> i % 2 == 0)
        .collect(Collectors.toList());
System.out.println("firstPeek：" + firstPeek);
System.out.println("secondPeek：" + secondPeek);
System.out.println("result：" + result);
结果：
firstPeek：[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
secondPeek：[6, 7, 8, 9, 10]
result：[6, 8, 10]
```

2. 使用idea的[调试功能](https://www.jetbrains.com/help/idea/analyze-java-stream-operations.html)

![img](https://static001.geekbang.org/resource/image/44/04/44a6f4cb8b413ef62c40a272cb474104.jpg)

# for循环

```java
// 第一种方法
gamesList.forEach(games -> System.out.println(games));  
// 第二种方法
gamesList.forEach(System.out::println);  
```

# 参考

[深入剖析 Java 新特性](https://time.geekbang.org/column/intro/100097301)

[Java 帝国之函数式编程](https://mp.weixin.qq.com/s?__biz=MzAxOTc0NzExNg==&mid=2665513149&idx=1&sn=00e563fbd09c9cf9e2ac4283d43cccf1&scene=21#wechat_redirect)

[Java 帝国之函数式编程](https://mp.weixin.qq.com/s?__biz=MzAxOTc0NzExNg==&mid=2665513152&idx=1&sn=1398826ca9f9ea2b7c374574302a3838&scene=21#wechat_redirect)

https://www.oracle.com/java/technologies/javase/8-whats-new.html

https://www.javatpoint.com/java-8-features

Java实战(第二版)
