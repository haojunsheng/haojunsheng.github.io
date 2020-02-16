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

#### 1.1.3.2 ArrayList和LinkedList和Vector的区别

https://github.com/haojunsheng/JavaLearning/blob/master/Java-basic/Java-collection/ArrayList-LinkedList-Vector.md



## 1.2 并发编程



## 1.3 jvm



