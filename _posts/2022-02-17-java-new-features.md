---
layout: post
title: "Java新特性"
date: 2022-02-17
description: "2022-02-17-java-new-features"
categories: Java
tag: [Java]
---

# 前言

Java新特性

# lambda表达式

[Java 帝国之函数式编程](https://mp.weixin.qq.com/s?__biz=MzAxOTc0NzExNg==&mid=2665513149&idx=1&sn=00e563fbd09c9cf9e2ac4283d43cccf1&scene=21#wechat_redirect)

[Java 帝国之函数式编程](https://mp.weixin.qq.com/s?__biz=MzAxOTc0NzExNg==&mid=2665513152&idx=1&sn=1398826ca9f9ea2b7c374574302a3838&scene=21#wechat_redirect)

Java编程偏向于命令式的，准确告诉计算机如何做。函数式编程则偏向于声明式的，类似于SQL。

Java 8之前和函数式编程的一个巨大的鸿沟是：Java是强类型的，我们如果要在Java上支持强类型，则需要给函数确定一个类型。

Java8则设计了基于Lambda表达式的类型推断，如

```java
() -> System.out.println("Hello Lambda");
s-> s.toUpperCase();
(x,y) -> x +y ; 
```

本质上而言，Lambda就是匿名函数。 箭头(->) 左边是**函数的参数列表**， 右边是**方法体**。

那么，Lambda表达式自然也是可以嵌套的。

我们定义了一个接口：

```java
public interface StringFuction{
        public String apply(String s);        
}
```

我们实现了一个函数：

```java
public String run (StringFuction f){
        return f.apply("Ｈello Ｗorld");
}
```

我们可以这么用：

```java
run (s -> s.toUpperCase()) ;  HELLO WORLD
run (s -> s.toLowerCase()) ;  hello world
```

本质上：s -> s.toUpperCase()表达式的类型是StringFuction，由编译器进行类型推断。

本质上：这个StringFunction 的apply方法接收一个字符串参数， 然后返回另外一个字符串的值。

这个等价于我们的匿名类：

```java
run(new StringFuction(){            
     public String apply(String s) {
                return s.toUpperCase();
      }
});
```

因此，如果我们这么写：run(s -> s.length())就会编译失败。

本质上而言，为了维护Java的强类型，需要定义一个函数接口，编译器会把Lambda表达式和接口进行匹配。在jdk中引入了java.util.function包，定义了下面这些接口：

```java
// 1. Function函数接口： 传入一个类型为T的参数， 返回一个类型为R 的参数
public interface Function<T,R>{
    R apply(T t);
    ......
}

// 2. Predicate<T> 函数接口：传入一个类型为Ｔ　的参数，　返回boolean
public interface Predicate<T> {
    boolean test(T t);
    ......
}
// 3. Consumer<T>函数接口：传入一个类型为T的参数，没有返回值
public interface Consumer<T> {
    void accept(T t);
    ......
}
// 4. Supplier<T>接口，返回一个类型为T的参数
public interface Supplier<T> {
    T get();
}
// BinaryOperator<T>接口，
s -> s.length()  就可以匹配 (1)   
x -> x>5   就可以匹配 (2) 
s ->  System.out.println(s)  就可以匹配 (3) 
() -> "OK" 可以匹配到(4)
```

Java引入了Stream来实现延迟计算（惰性求值的功能）。

```java
public class EvenNumber implements Supplier<Long>{
    long num = 0;
    @Override
    public Long get() {
        num += 2;
        return num ;
    }    
}
// numbers代表无穷无尽的偶数序列，只是没有计算出来而已
Stream<Long> numbers = Stream.generate(new EvenNumber());
numbers.limit(5).forEach(x->System.out.println(x));
输出： 2 4 6 8 10
```

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

![img](https://static001.geekbang.org/resource/image/44/04/44a6f4cb8b413ef62c40a272cb474104.jpg)

![img](https://static001.geekbang.org/resource/image/5a/de/5af5ba60d7af2c8780b69bc6c71cf3de.png)

# 参考

[深入剖析 Java 新特性](https://time.geekbang.org/column/intro/100097301)

