---
layout: post
title: "面试所需基础知识"
date: 2020-02-05
description: "2020-02-05-面试所需基础知识"
categories: 面试
tag: 面试

---

<!--ts-->

<!--te-->

# 1. Java

## 1.1 java基础

### 1.1.1 面向对象

#### 1.1.1.1 什么是面向对象？

- 什么是面向过程：把问题分解成一个一个步骤，每个步骤都是函数或者表达式，这样的编程思想就是面向过程。
- 什么是面向对象:对象是属性和行为的集合体。把问题分解成一个一个步骤，每个步骤都是对象及对象的行为调用，这样的编程思想就是面向对象。
- 三大基本特征：
  - 封装：所谓封装，也就是把客观事物封装成抽象的类，并且类可以把自己的数据和方法只让可信的类或者对象操作，对不可信的进行信息隐藏。封装是面向对象的特征之一，是对象和类概念的主要特性。简单的说，一个类就是一个封装了数据以及操作这些数据的代码的逻辑实体。在一个对象内部，某些代码或某些数据可以是私有的，不能被外界访问。通过这种方式，对象对内部数据提供了不同级别的保护，以防止程序中无关的部分意外的改变或错误的使用了对象的私有部分。https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/java-encapsulation.md
  - 继承:继承是指这样一种能力：它可以使用现有类的所有功能，并在无需重新编写原来的类的情况下对这些功能进行扩展。通过继承创建的新类称为“子类”或“派生类”，被继承的类称为“基类”、“父类”或“超类”。继承的过程，就是从一般到特殊的过程。要实现继承，可以通过“继承”（Inheritance）和“组合”（Composition）来实现。继承概念的实现方式有二类：实现继承与接口继承。实现继承是指直接使用基类的属性和方法而无需额外编码的能力；接口继承是指仅使用属性和方法的名称、但是子类必须提供实现的能力；https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/java-extend.md
  - 多态:所谓多态就是指一个类实例的相同方法在不同情形有不同表现形式。多态机制使具有不同内部结构的对象可以共享相同的外部接口。这意味着，虽然针对不同对象的具体操作不同，但通过一个公共的类，它们（那些操作）可以通过相同的方式予以调用。最常见的多态就是将子类传入父类参数中，运行时调用父类方法时通过传入的子类决定具体的内部结构或行为。https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/polymorphic.md
- 五大原则:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/five-basic-for-object-oriented.md
  - S：单一职责原则:一个类，最好只做一件事，只有一个引起它的变化。
  - O：开放封闭原则:软件实体应该是可扩展的，而不可修改的。也就是，对扩展开放，对修改封闭的。
  - L：里氏替换原则:子类必须能够替换其基类。
  - I：接口隔离原则
  - D：依赖倒置原则

#### 1.1.1.2 平台无关性

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/what-is-platform-independent.md

#### 1.1.1.3 值传递

Java中只有值传递。https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/java-only-value-pass.md

- 形参和实参：前者是用于接收实参内容的参数，后者是真正传递的内容。
- 值传递和引用传递的区别在于：**传递后会不会影响实参的值**，前者会创建副本，后者不会创建副本。

#### 1.1.1.4 重载（Overloading）和重写（Overriding）

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-analyze-override-overloading.md

- 重载：签名不一样。
- 重写：子类重写父类，签名一样。

#### 1.1.1.5 组合和继承

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-analyze-override-overloading.md

- 多用组合，少用继承。
- 只有需要从新类向基类进行向上转型的时候，才使用继承。

#### 1.1.1.6成员变量和方法的作用域

- public :表明该成员变量或者方法是对所有类或者对象都是可见的,所有类或者对象都可以直接访问
- private:表明该成员变量或者方法是私有的,只有当前类对其具有访问权限,除此之外其他类或者对象都没有访问权限.子类也没有访问权限.
- protected:表明成员变量或者方法对类自身,与同在一个包中的其他类可见,其他包下的类不可访问,除非是他的子类
- default:表明该成员变量或者方法只有自己和其位于同一个包的内可见,其他包内的类不能访问,即便是它的子类
- 值得注意的是，外部类的作用域只有public和default。因为如果是private，那么别的类就无法对其进行实例化，毫无意义。对于protected，类B继承类A的前提又是类B可以访问到类A。继承的核心是继承属性和方法，在说一句，只有可以访问到，才有继承。所以类的修饰符只有public和default。

#### 1.1.1.7 抽象类和接口

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/abstract-class-vs-interface.md

- 抽象类：对类整个整体抽象
- 接口：对行为进行抽象

#### 1.1.1.8 内部类

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/object-oriented/inner-class.md

- 解决多重继承问题。

### 1.1.2 基础知识

#### 1.1.2.1 基本数据类型

7种基本类型：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-basic-data-type.md

#### 1.1.2.2 自动拆装箱

1. 自动拆装箱：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-auto-unbox.md
2. Integer的缓存机制:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Integer-cache.md

#### 1.1.2.3 String相关

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/String-detail.md

- 字符串的不可变性（String是用final数组实现的）

- JDK 6和JDK 7中substring的原理及区别、

- replaceFirst、replaceAll、replace区别、

- String对“+”的重载、字符串拼接的几种方式和区别

- String.valueOf和Integer.toString的区别、

- switch对String的支持

- 字符串池、常量池（运行时常量池、Class常量池）、intern

#### 1.1.2.4 java关键字

##### 1.1.2.4.1 transient

禁止某个变量序列化。

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/transient-keyword.md

1）一旦变量被transient修饰，变量将不再是对象持久化的一部分，该变量内容在序列化后无法获得访问。

2）transient关键字只能修饰变量，而不能修饰方法和类。注意，本地变量是不能被transient关键字修饰的。变量如果是用户自定义类变量，则该类需要实现Serializable接口。

3）被transient关键字修饰的变量不再能被序列化，一个静态变量不管是否被transient修饰，均不能被序列化。

##### 1.1.2.4.2 instanceof



##### 1.1.2.4.3 volatile

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-understand-Java-volatile.md

##### 1.1.2.4.4 synchronized

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-undaunted-synchronized.md

##### 1.1.2.4.5 final

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/final-principle-use.md

不想被改变的原因有两个：**效率、设计**。

- final常量
  - 编译期常量，永远不可改变。只能使用基本类型，而且必须要在定义时进行初始化。
  - 运行期初始化时，我们希望它不会被改变。希望它可以根据对象的不同而表现不同，但同时又不希望它被改变，这个时候我们就可以使用运行期常量。对于运行期常量，它既可是基本数据类型，也可是引用数据类型。**基本数据类型不可变的是其内容，而引用数据类型不可变的是其引用，引用所指定的对象内容是可变的。**
- final方法
  - 所有被final标注的方法都是不能被继承、更改的
  - 方法锁定，以防止任何子类来对它的修改
- final类
  - 该类是最终类，它不希望也不允许其他来继承它
- final参数
  - 代表了该参数是不可改变的
- final & static
  - 同时使用时即可修饰成员变量，该变量一旦赋值就不能改变，我们称它为“全局常量”。可以通过类名直接访问。
  - 可修饰成员方法。是不可继承和改变。可以通过类名直接访问。  
  - final强调的是常量
  - static强调的生命周期

##### 1.1.2.4.6 staic

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/static-principle-use.md

- static变量
  - 静态变量是随着类加载时被完成初始化的，它在内存中仅有一个，且JVM也只会为它分配一次内存，同时类所有的实例都共享静态变量，可以直接通过类名来访问它。
  - 实例变量则不同，它是伴随着实例的，每创建一个实例就会产生一个实例变量，它与该实例同生共死。
- static方法
  - 通过类名对其进行直接调用
- static代码块
  - 被static修饰的代码块，我们称之为静态代码块，静态代码块会随着类的加载一块执行，而且他可以随意放，可以存在于该了的任何地方。
- 执行顺序
  - 静态代码块 > 构造代码块 > 构造函数

##### 1.1.2.4.7 const



##### 1.1.2.4.8 length vs length()

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-analyze-java-length-length().md

- 数组有length属性，数组的长度可以作为`final`实例变量的长度。因此，长度可以被视为一个数组的属性。
- String有length()方法。String背后的数据结构是一个char数组,所以没有必要来定义一个不必要的属性。

##### 1.1.2.4.9 Comparable vs Comparator

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/Java-Comparable-Comparator.md

##### 1.1.2.4.10 ktve

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/Java-K-T-V-E.md

E – Element (在集合中使用，因为集合中存放的是元素)

T – Type（Java 类）

K – Key（键）

V – Value（值）

N – Number（数值类型）

？ – 表示不确定的java类型（无限制通配符类型）

S、U、V – 2nd、3rd、4th types

Object – 是所有类的根类，任何类的对象都可以设置给该Object引用变量，使用的时候可能需要类型强制转换，但是用使用了泛型T、E等这些标识符后，在实际用之前类型就已经确定了，不需要再进行类型强制转换。

##### 1.1.2.4.11 重载与重写

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/deep-analyze-override-overloading.md

##### 1.1.2.4.12 equals和hashcode的协同工作

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/Java-equals-hashcode.md

##### 1.1.2.4.13 迭代和递归

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/Java-iteration-recursion.md

##### 1.1.2.4.14 swith

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-keyword/Java-Switch.md

### 1.1.3 集合

#### 1.1.3.1 常用集合类的使用

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/collection-family.md

- 数组：数组是**将数字和对象联系起来**，它**保存明确的对象**。（固定大小）
- Collection：保存单一的元素（可扩容）
  - list:有序可重复的Collection，注意，有序指的是放入顺序，而不是大小顺序。
    - ArrayList：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/List/ArrayList.md
      - 使用数组来实现；
      - 默认容量10；
      - 每次添加新的元素时，ArrayList都会检查是否需要进行扩容操作，**扩容操作带来数据向新数组的重新拷贝**，每次扩容是1.5倍
      - 不是线程安全的
    - LinkedList:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/List/LinkedList.md
      - 使用链表来实现
      - 非线程安全的
    - Vector:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/List/Vector.md
      - 线程安全
    - SynchronizedList vs Vector： https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/List/SynchronizedList-vs-Vector.md
      - 前者同步代码块，后者同步方法
      - 扩容方式不同，前者增加50%，后者增加1倍
    - Stack:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/List/Stack.md
      - Stack继承自Vector,实现一个后进先出的堆栈.
      - 线程安全
  - set无序不可重复
    - HashSet:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Set/HashSet.md
    - TreeSet:https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Set/TreeSet.md
  - queue
- map：保存相关联的值键对https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/Map.md
  - Hashmap：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/HashMap.md
  - Hashtable：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/HashTable.md
  - TreeMap：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/TreeMap.md
  - hashmap初始化：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/HashMap-initialize.md
  - Map中的hash：https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/Map/Map-hash().md

#### 1.1.3.2 ArrayList和LinkedList和Vector的区别

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/ArrayList-LinkedList-Vector.md

#### 1.1.3.3 SynchronizedList和Vector的区别

[HashMap、HashTable、ConcurrentHashMap区别](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/HashMap-HashTable-ConcurrentHashMap.md)

[Set和List区别？](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/set-vs-list.md)

[Set如何保证元素不重复?](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/set-repetition.md)

[Java 8中stream相关用法](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/stream.md)、

apache集合处理工具类的使用、

不同版本的JDK中HashMap的实现的区别以及原因

[Collection和Collections区别](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/Collection-vs-Collections.md)

[Arrays.asList获得的List使用时需要注意什么](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/Arrays-asList.md)

[Enumeration和Iterator区别](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/Enumeration-vs-Iterator.md)

[fail-fast 和 fail-safe](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/fail-fast-vs-fail-safe.md)

[CopyOnWriteArrayList](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/CopyOnWriteArrayList.md)

[ConcurrentSkipListMap](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/ConcurrentSkipListMap.md)

### 1.1.4 枚举

[枚举的用法](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-enum/Java-enum-use.md)

[枚举的实现](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-enum/enum-impl.md)

[枚举与单例](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-enum/seven-singleton-pattern.md)

[Enum类:](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-source-code/Enum.md)

**Java枚举如何比较:**

java 枚举值比较用 == 和 equals 方法没啥区别，两个随便用都是一样的效果。

因为枚举 Enum 类的 equals 方法默认实现就是通过 == 来比较的；

类似的 Enum 的 compareTo 方法比较的是 Enum 的 ordinal 顺序大小；

类似的还有 Enum 的 name 方法和 toString 方法一样都返回的是 Enum 的 name 值。

**switch对枚举的支持**

Java 1.7 之前 switch 参数可用类型为 short、byte、int、char，枚举类型之所以能使用其实是编译器层面实现的，编译器会将枚举 switch 转换为类似 switch(s.ordinal()) { case Status.START.ordinal() } 形式，所以实质还是 int 参数类型，感兴趣的可以自己写个使用枚举的 switch 代码然后通过 javap -v 去看下字节码就明白了。

[枚举的序列化如何实现](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-enum/enum-serializable.md)

[枚举的线程安全性问题](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-enum/deep-learning-java-enum-thread-safe.md)

### 1.1.5 IO

[java i/o完全解读](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-IO/Java-IO-all.md)

字符流、字节流、输入流、输出流、

同步、异步、阻塞、非阻塞、Linux 5种IO模型

BIO、NIO和AIO的区别、三种IO的用法与原理、netty

### 1.1.6 反射

[反射与工厂模式](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-reflect/java-factory-union-reflect.md)

**反射有什么作用**：

在运行时判断任意一个对象所属的类。

在运行时判断任意一个类所具有的成员变量和方法。

在运行时任意调用一个对象的方法。

在运行时构造任意一个类的对象。



Class类

java.lang.reflect.*

动态代理

静态代理、动态代理

动态代理和反射的关系

动态代理的几种实现方式

AOP

### 1.1.7 序列化

什么是序列化与反序列化、为什么序列化、序列化底层原理、序列化与单例模式、protobuf、为什么说序列化并不安全

### 1.1.8 注解

元注解、自定义注解、Java中常用注解使用、注解与反射的结合

[如何自定义一个注解？](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/create-annotation.md)

[Spring常用注解](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/annotation-in-spring.md)

### 1.1.9 泛型

泛型与继承、类型擦除、[泛型中K T V E ？ object等的含义](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/k-t-v-e.md)、泛型各种用法

限定通配符和非限定通配符、上下界限定符extends 和 super

[List和原始类型List之间的区别?](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/genericity-list.md)

[List和List之间的区别是什么?](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/genericity-list-wildcard.md)

## 1.1.10 异常

异常类型、正确处理异常、自定义异常

Error和Exception

异常链、try-with-resources

finally和return的执行顺序

### 1.1.11 语法糖

[Java中语法糖原理、解语法糖](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/syntactic-sugar.md)

[自动拆箱与装箱](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/java-auto-unbox.md)

[语法糖：switch 支持 String 与枚举、泛型、自动装箱与拆箱、方法变长参数、枚举、内部类、条件编译、 断言、数值字面量、for-each、try-with-resource、Lambda表达式](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/syntactic-sugar.md)

## 1.2 并发编程

这个玩意和java的内存模型是息息相关的，二者可以结合着看。

### 1.2.1 并发与并行

[并发与并行的区别](https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-Concurrent-programming/1-what-is-thread-safe.md)

什么是并发

什么是并行

并发与并行的区别

### 1.2.2 线程

线程的实现、线程的状态、优先级、线程调度、创建线程的多种方式、守护线程

线程与进程的区别

#### 线程池

自己设计线程池、submit() 和 execute()、线程池原理

为什么不允许使用Executors创建线程池

#### 线程安全

[死锁？](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/deadlock-java-level.md)、死锁如何排查、线程安全和内存模型的关系

#### 锁

CAS、乐观锁与悲观锁、数据库相关锁机制、分布式锁、偏向锁、轻量级锁、重量级锁、monitor、

锁优化、锁消除、锁粗化、自旋锁、可重入锁、阻塞锁、死锁

#### 死锁

死锁的原因

死锁的解决办法

#### synchronized

[synchronized是如何实现的？](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/java-basic/synchronized.md)

synchronized和lock之间关系、不使用synchronized如何实现一个线程安全的单例

synchronized和原子性、可见性和有序性之间的关系

#### volatile

happens-before、内存屏障、编译器指令重排和CPU指令重排

volatile的实现原理

volatile和原子性、可见性和有序性之间的关系

有了symchronized为什么还需要volatile

#### sleep 和 wait

#### wait 和 notify

#### notify 和 notifyAll

#### ThreadLocal

#### 写一个死锁的程序

#### 写代码来解决生产者消费者问题

### 并发包

#### 阅读源代码，并学会使用

Thread、Runnable、Callable、ReentrantLock、ReentrantReadWriteLock、Atomic*、Semaphore、CountDownLatch、、ConcurrentHashMap、Executors

## 1.3 jvm

### 1.3.1 jvm内存结构

掌握：

- [class文件格式](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/Class-strcture.md)

这个玩意可以帮我们看懂字节码，如果有增强字节码的需求也是看这里。主要是搞明白字节码结构图。java字节码是按照一定的规则来组成的，这样jvm才可以进行解释。

- [运行时数据区：堆、栈、方法区、直接内存](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/jvm-memory-component-heap.md)

这个玩意必须得区分清楚，尤其是堆栈方法区这三个。我们的关键是整明白，为什么要分这三个区？我的理解是：

其中，在c语言的世界里，是没有方法区的概念的，是java引入的，所以大胆猜测，方法区的引入和2个因素有关系：

1. java是解释性的语言，字节码在被jvm加载后，必须要有个地方来存储。存放在堆和栈里又不合适。
2. 为了支持面向对象的特性:在面向过程中，都是函数，所以用栈和堆足够了。

所以我们把**类的信息，以及一些实例无关的信息(即编译器被确定的值)**放到了方法区。

在来看堆与栈，**栈是用来存储局部变量和计算的过程，堆用来存储实例**。

这些的区分一定是为了效率。需要考虑变量的生命周期，访问的速度，空间大小，使用过程中是否保持有序。

- [方法区和运行时常量池](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/method-area-constants-pool.md)

常量池分为class常量池，运行时常量池，字符串常量池。

class常量池中的字面量和符号引号（**符号引用主要是用来重定位的**）的概念很重要，需要掌握。这两个玩意都是编译原理里面的。常量是怎么存储的，也很重要，和数据类型是息息相关的。

运行时常量池里保存了符号引用，进而解析为直接引用。

字符串常量池则比较复杂，在不同版本的虚拟机中是不同的，最开始在方法区中，后来移入到了堆中，在后来移动到了本地内存中。

- [堆和栈区别](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/heap-vs-stack.md)

[Java中的对象一定在堆上分配吗？](https://github.com/hollischuang/toBeTopJavaer/blob/master/basics/jvm/stack-alloc.md)

### 1.3.2 Java内存模型

计算机内存模型、缓存一致性、MESI协议

可见性、原子性、顺序性、happens-before、

内存屏障、synchronized、volatile、final、锁

[java内存模型](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/Java-memory-model.md)

这个玩意需要我们好好去学，学好了这个也就入门了并发编程，这个复杂的问题，而这个问题，在面试中也是要必考的。我们需要回答：**Java内存模型是什么，为什么要有Java内存模型，Java内存模型解决了什么问题？**

由于我们抽象了计算机的硬件,在多线程的情况下,会带来**缓存一致性问题**。为了使处理器内部的运算单元能够尽量的被充分利用，处理器可能会对输入代码进行乱序执行处理。这就是**处理器优化**，会进一步带来指令重排的问题。

这三个问题对应了我们讲的**原子性，可见性和有序性**问题。这三个问题是核心的问题，我做了一系列的工作就是为了解决这三个问题。

**原子性**是指在一个操作中就是cpu不可以在中途暂停然后再调度，既不被中断操作，要不执行完成，要不就不执行。

**可见性**是指当多个线程访问同一个变量时，一个线程修改了这个变量的值，其他线程能够立即看得到修改的值。

**有序性**即程序执行的顺序按照代码的先后顺序执行。

我们对此进行对应，**缓存一致性问题**其实就是**可见性问题**，而**处理器优化**是可以导致**原子性问题**的，**指令重排**即会导致**有序性问题**。

所以我们定义了内存模型，来解决上面的问题，主要是**限制处理器优化**和**使用内存屏障**。

那么我们比较关注的是java内存模型究竟是怎么实现的？

我们可以看到的是java为我们提供了这些关键字`volatile`、`synchronized`、`final`、`concurren`来封装了java内存模型底层的实现了。

原子性主要依靠：两个高级的字节码指令`monitorenter`和`monitorexit`，对应java中的`synchronized`。

可见性是指每次修改完立即同步到主存，读取前从主存刷新，依靠`volatile`。

我们使用`synchronized`和`volatile`来保证有序性，区别是`synchronized`关键字保证同一时刻只允许一条线程操作，`volatile`关键字会禁止指令重排。

我们好奇的是java的内存模型解决了缓存一致性问题，那么到底是怎么解决的呢？

在最开始，我们是通过在总线上加锁来实现的，但是导致效率低下的问题，后来我们采用缓存一致性协议来解决。

其中，最著名的协议是Intel 的MESI协议。MESI协议保证了**每个缓存中使用的共享变量的副本是一致的。**核心思想是：当CPU写数据时，如果发现操作的变量是共享变量，即在其他CPU中也存在该变量的副本，会发出信号通知其他CPU将该变量的缓存行置为无效状态，因此当其他CPU需要读取这个变量时，发现自己缓存中缓存该变量的缓存行是无效的，那么它就会从内存重新读取。

我们需要了解[synchronized](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/deep-understand-multi-thread.md#1synchronized%E7%9A%84%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86)和volatile究竟是怎么实现的。

- 其中Synchronized对原子性的保证是通过（monitorenter和monitorexit）来实现的，对可见性是通过(加锁来实现的），对有序性是通过（as-if-serial）语义来实现的。Synchronized能修饰变量，方法和代码块。

- Volatile对可见性是通过（强制刷新内存，强制从内存读进行实现的），对有序性是通过禁止指令重排实现的(增加了内存屏障)。但是不能保证原子性，因为并没有加锁。Volatile只能修饰变量，不能修饰方法和代码块。

### 1.3.3 Java对象模型

[对象模型](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/deep-understand-multi-thread.md#21-java的对象模型)

java的对象模型主要包含对象头，实例数据和对齐填充，主要是研究java的对象是怎么存储的。其中对象头是很重要的。

到这里，我们需要对内存结构，内存模型和对象模型做一个区分：

[内存结构vs内存模型vs对象模型](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/jvm-memoryStrcture-vs-memoryModel-vs-objectModel.md)

内存结构讲的是java内存的划分，和运行时区域有关系；

内存模型用来解决java的并发编程问题的，和原子性，有序性，可见性有关。

### 1.3.4 Java的垃圾回收机制

GC算法：标记清除、引用计数、复制、标记压缩、分代回收、增量式回收

GC参数、对象存活的判定、垃圾收集器（CMS、G1、ZGC、Epsilon）

[垃圾回收](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/garbage-collection.md)

[Java之美从菜鸟到高手演变\]之JVM内存管理及垃圾回收 - CSDN博客](https://blog.csdn.net/zhangerqing/article/details/8214365)

[JVM 自动内存管理：对象判定和回收算法-极客学院](http://www.jikexueyuan.com/course/2098.html)

[Java 技术，IBM 风格: 垃圾收集策略，第 1 部分](https://www.ibm.com/developerworks/cn/java/j-ibmjava2/)

[JVM 垃圾回收器工作原理及使用实例介绍](https://www.ibm.com/developerworks/cn/java/j-lo-JVMGarbageCollection/)

### 1.3.5 HotSpot虚拟机

[即时编译器、编译优化](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/HotSpot.md)等相关知识。

优化对现阶段的我不是很重要。

[深入浅出 JIT 编译器](https://www.ibm.com/developerworks/cn/java/j-lo-just-in-time/index.html)

[什么是即时编译（JIT）！？OpenJDK HotSpot VM剖析](http://www.infoq.com/cn/articles/OpenJDK-HotSpot-What-the-JIT)

[深入分析Java的编译原理-HollisChuang's Blog](http://www.hollischuang.com/archives/2322)（密码：Hollis和他的朋友们）

[对象和数组并不是都在堆上分配内存的。-HollisChuang's Blog](http://www.hollischuang.com/archives/2398)

### 1.3.6 [类加载机制](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/class-loader.md)

双亲委派，破坏双亲委派。

参考资料：

[Java类的加载、链接和初始化-HollisChuang's Blog](http://www.hollischuang.com/archives/201)

[深度分析Java的ClassLoader机制（源码级别）-HollisChuang's Blog](http://www.hollischuang.com/archives/199)

[双亲委派模型与自定义类加载器 - ImportNew](http://www.importnew.com/24036.html)

[Java双亲委派模型及破坏 - CSDN博客](https://blog.csdn.net/zhangcanyan/article/details/78993959)

### 1.3.7 [常用Java命令](https://github.com/haojunsheng/JavaLearning/blob/master/jvmLearning/java-command.md)

javac 、javap 、jps、jstack,jinfo、jstat 、jmap 、jhat

### 1.3.8 编译与反编译

Java中的编译与反编译。什么是编译？什么是反编译？Java如何编译代码，如何反编译代码？尝试反编译switch、String的“+”、lambda表达式、java 10的本地变量推断等。

[深入分析Java的编译原理-HollisChuang's Blog](http://www.hollischuang.com/archives/2322)

[Java代码的编译与反编译那些事儿-HollisChuang's Blog](http://www.hollischuang.com/archives/58)

[我反编译了Java 10的本地变量类型推断-HollisChuang's Blog](http://www.hollischuang.com/archives/2187)

[Java命令学习系列（七）——javap-HollisChuang's Blog](http://www.hollischuang.com/archives/1107)

[Java中的Switch对整型、字符型、字符串型的具体实现细节-HollisChuang's Blo...](http://www.hollischuang.com/archives/61)

# 2. 数据结构与算法



