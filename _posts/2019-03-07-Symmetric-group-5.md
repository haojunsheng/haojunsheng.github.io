---
layout: post
title: "区块链中的密码学之对称密码的分组模式（五）"
date: 2019-03-07 
description: "2019-03-07-区块链中的密码学之对称密码的分组模式（五）"
categories: 密码学
tag: [密码学,对称加密算法,分组密码]
---

<!--ts-->
   * [1. 前言](#1-前言)
   * [2. 分组密码系统模型](#2-分组密码系统模型)
   * [3. <strong>分组密码的设计思想</strong>](#3-分组密码的设计思想)
   * [4. SP网络](#4-sp网络)
   * [5. Feistel密码结构](#5-feistel密码结构)
   * [6.  分组密码的工作模式](#6--分组密码的工作模式)
      * [6.1  分组密码的填充](#61--分组密码的填充)
      * [6.2  分组密码的工作模式](#62--分组密码的工作模式)
      * [6.3 分组密码运行模式比较](#63-分组密码运行模式比较)
      * [6.4  <strong>分组密码的分析</strong>](#64--分组密码的分析)

<!-- Added by: anapodoton, at: 2019年12月 9日 星期一 14时56分46秒 CST -->

<!--te-->
# 1. 前言

 众所周知，由于对称加密算法只能加密固定长度的明文。如果我们想加密任意长度的明文，则需要对明文进行分组，然后对每组进行加密。

在密码学中，被称为**分组加密**（**Block cipher**）。将明文分成多个等长的模块，然后使用算法对每组进行加密。现代的分组加密的是创建在迭代的思想上的，这种思想来自

香农的《保密系统的通信理论》。哈哈，就是我们在本科学习到的那个大佬香农。值得注意的是，<u>迭代产生的密文在每一轮中使用不同的子密钥，而这些子密钥由原密钥生成。</u>

如何设计密码结构，才能让安全性更强，加解密算法 效率更高、更易于实现呢?



# 2. 分组密码系统模型

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1ibdh4v6gj31200b60yp.jpg)

   分组密码实质上是字长为m的数字序列的代换密码。注意，在一般情况下，n和m是相等的。

**分组密码的概念：**

<u>分组密码(块密码)，将明文消息编码表示后的数字序列，划分成固定大小的组(块)，各组分别在密钥的控制下变换成等长的输出数字序列。</u>

 ![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hrvc1w19j30q60miq9u.jpg)

# 3. **分组密码的设计思想**

**扩散(diffusion)：**将明文冗余度分散到密文中。进行扩散最简单的方法是置换（Permutation），即重新排列字符。

**混淆(confusion)：**让明文和密文之间的关系复杂化，这样做是为了防止通过统计分析进而破译密码学。常用的方法是替换换(Substitution)。

在实际中，代换常用代换表，用查表法来实现。常用的基本代换有以下几种：

1. 循环移位(Shift left/right circular)
2. 模2n加 (Addition with module) 
3. 线性变换(Linear transformation) 
4. 换位/置换(Transposition)
5. 仿射变换(Affine transform)

**分组密码要满足以下要求：**

分组长度足够大(64~128~256比特)；

密钥量要足够大(64~128~192~256比特）；

算法足够复杂(包括子密钥产生算法)；

加密、解密算法简单，易软、硬件实现；

便于分析(破译是困难的，但算法却简洁清晰)；

# 4. SP网络

**概念**：SP网络(Substitution-permutation Network，替换-置换网络)，是一种特殊的迭代密码体制，较好地实现混淆与扩散。

**SP网络设计思想：**

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hrzh233nj30e80m0gsx.jpg)

输入状态：W^r-1是r-1轮对s盒的输入。

S替换的基本性质是其非线性映射，它的输出不能通过对输入的线性变换得到，使密文与密钥之间的关系复杂化，使明文和密钥充分混合在一起，难以从密文提取出明文或者密钥信息。

P置换是让明文的统计特征消散在密文中，让明文的每一比特影响尽可能多的每一比特。

**SP网络的加密**

将每一轮的比特输入和子密钥进行简单的异或运算,每一轮的子密钥都是通过加密主密钥变换产生的，相互之间应当没有联系。

![006tKfTcly1g1i9w53vrfj31aw07oafo](/images/posts/crypto/006tKfTcly1g1i9w53vrfj31aw07oafo.jpg)



**SP网络的解密**

子密钥必须与加密相反的次序使用，子密钥的使用要与p置换一致，来保证正确解密。

![006tKfTcly1g1i9y2wj0hj31b607gted](/images/posts/crypto/006tKfTcly1g1i9y2wj0hj31b607gted.jpg)

通过替--置换的多次迭代很好的实现混淆与扩散。

# 5. Feistel密码结构

**基本概念：**

以发明者 Horst Feistel为名; 

对称结构，是典型的迭代密码; 

使用乘积密码的概念，交替使用替换和置换来进行加密解密。

典型代表:DES算法 

**Feistel密码结构的设计思想**

![006tKfTcly1g1ia51defkj30wc0lcq9r](/images/posts/crypto/006tKfTcly1g1ia51defkj30wc0lcq9r.jpg)

 **Feistel网络的加密结构**：将2w bit明文分成为左右两半、长为1 w bit的段，以L和R表示。然后进行n轮迭代，其第i轮迭代的输入为上一轮（第i-1轮）输出。

轮函数的意义是上一轮的输出。

![006tKfTcly1g1ia5zlu0uj30xe0qiasr](/images/posts/crypto/006tKfTcly1g1ia5zlu0uj30xe0qiasr.jpg)

**替换操作：**

替代作用在数据左半部分完成

轮函数F作用于数据的右半部分后， 与左半部分数据进行异或来完成。 

每轮输入的子密钥Ki不同 

<img src="/images/posts/crypto/006tKfTcly1g1ia79hqb5j30mu0mk479.jpg" alt="006tKfTcly1g1ia79hqb5j30mu0mk479" style="zoom:33%;" />



<img src="/images/posts/crypto/006tKfTcly1g1ia7pfy5bj30ks0ocdod.jpg" alt="006tKfTcly1g1ia7pfy5bj30ks0ocdod" style="zoom:33%;" />



<img src="/images/posts/crypto/006tKfTcly1g1ia84bpqwj30x60putk2.jpg" alt="006tKfTcly1g1ia84bpqwj30x60putk2" style="zoom:33%;" />

# 6.  分组密码的工作模式

前面我们知道，分组密码在加密时明文分组的长度是固定的，而实用中待加密消息的数据量是不定的，数据格式可能是多种多样的。所以我们需要进行分组。为了更好的隐蔽明文的统计特性、数据的格式等，以提高整体的安全性， 降低删除、重放、插入和伪造成功的机会。我们必须要选用适当的分组运行模式。

## 6.1  分组密码的填充

明文长度不足或超过固定分组的长度整数倍，可以用**填充**的方法。

现代自动分组加密中，加密填充的字符解密时如何检测?

![006tKfTcly1g1iaku6cf3j30vw088760](/images/posts/crypto/006tKfTcly1g1iaku6cf3j30vw088760.jpg)

## 6.2  分组密码的工作模式

将很长的明文全部进行加密，而对分组密码算法进行迭代的方法就称为分组密码的模式。

**1. 电子密码本（ECB）**

电子密码本(Electronic Code Book，ECB)是分组密码的基本工作方式，它将长的明文分成大小<u>相等</u>的分组，P=(P1，P2，...，PL)，<u>最后一组</u>在必要时需要进行填充，每组用<u>相同的密钥K</u>进行加密Cj=EK(Pj)，加密后将各组密文合并成密文消息C=(C1，C2，...，CL)。

![006tKfTcly1g1iap56p6xj310o0biwgu](/images/posts/crypto/006tKfTcly1g1iap56p6xj310o0biwgu.jpg)

**优点：**

有利于并行计算；
误差不会被扩散；
适合加密短小的消息；

**缺点**

不能隐藏明文的模式；
可能对明文进行主动攻击；
易受到重放、替换密文和频率分析攻击；

**2. 密码分组链接**（CBC）

密码分组链接(Cipher Block Chaining，CBC)模式，将明文分成大小**相等**的分组，将这些分组链接在一起进行加密，加密输入是当前明文分组和前一密文分组的异或，它们形成一条链，每次加密使用相同的**密钥**。

![006tKfTcly1g1iaspw9nrj316c0fedm4](/images/posts/crypto/006tKfTcly1g1iaspw9nrj316c0fedm4.jpg)

**优点**

增加安全性，使用最普遍；
适合传输长度长的报文；
应用于SSL、IPSec协议；

**缺点**

加密不支持并行计算；
误差传递；



在应用者，CBC是最为广泛的，在Fabric的AES算法的实现中，采用的就是CBC模式，源码地址：

https://github.com/hyperledger/fabric/blob/release-1.4/bccsp/sw/aes.go



**3. 密码反馈模式（CFB）**

密码反馈模式(Cipher FeedBack Mode)，将明文分成大小**相等的分组**，明文分组和密文分组间只有**异或**。

![006tKfTcly1g1iauztbudj30z40bqqcp](/images/posts/crypto/006tKfTcly1g1iauztbudj30z40bqqcp.jpg)

**优点**

不需要填充 ；

支持并行计算(仅解密)； 

 解密任意密文分组；
 用于传送数据流和认证；

**缺点**

不利于并行计算(加密)；
误差传递；
不能抵御重放攻击；

**4. 输出反馈模式（OFB）**

输出反馈模式(output-feedback )，加密算法的输入为前一次加密算法的输出。

![006tKfTcly1g1iaxf1pjsj30sa0emdob](/images/posts/crypto/006tKfTcly1g1iaxf1pjsj30sa0emdob.jpg)

**优点**

不需要填充 ；

事先进行加解密的准备；

 加解密使用相同结构；

解密错误比特的密文，只有相应明文的比特出错；

**缺点**

难以检测密文篡改；
要求系统严格同步；

**5. 计数器模式（CTR）**

CTR(Counter)模式中， 有一个自增的算子，这个算子用密钥加密之后的输出和明文异或的结果得到密文，相当于一次一密。

![006tKfTcly1g1iazf6joij30l20gs0za](/images/posts/crypto/006tKfTcly1g1iazf6joij30l20gs0za.jpg)

**优点：**

不需填充 ；

事先进行加解密的准备 ；

加解密使用相同的结构 ；

可以并行计算(加解密) ；

解密错误比特的密文，只有相应明文的比特出错；

**缺点**

反转密文分组中的某些比特，明文分组对应的比特会被反转。

## 6.3 分组密码运行模式比较

![006tKfTcly1g1ibm6fkyhj311y0mcqtt](/images/posts/crypto/006tKfTcly1g1ibm6fkyhj311y0mcqtt.jpg)



## 6.4  **分组密码的分析**

密码分析学中的假设：

​    人们总是假定攻击者可以截获在不安全信道上所传输的所有密文。

​    另一被广泛接受的假设是Kerchhoff假设：除密钥外，攻击者知道加密和解密的详细过程。

攻击分组密码常用的方法：

- 强力攻击：密钥穷尽搜索攻击。
- 差分密码分析：通过逐轮分析明文对的差值对密文对差值的影响来恢复密钥或密钥的某些比特。
- 线性分析：基本思想是通过寻找一个给定密码算法有效的线性近似表达式来分析破译密码系统。





