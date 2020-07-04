---
layout: post
title: "区块链中的密码学系列之对称密码概述(四）"
date: 2019-03-05
description: "2019-03-05-区块链中的密码学系列之对称密码概述(四）"
categories: 密码学

tag: [密码学,对称加密算法]
---   
<!--ts-->
   * [1. 前言](#1-前言)
   * [2. 置换密码](#2-置换密码)
      * [2.1 栅栏技术](#21-栅栏技术)
      * [2.2 周期置换](#22-周期置换)
      * [2.3 列置换](#23-列置换)
      * [2.4 多次列置换](#24-多次列置换)
   * [3. 替换密码](#3-替换密码)
      * [3.1 凯撒密码](#31-凯撒密码)
      * [3.2 维吉尼亚密码](#32-维吉尼亚密码)
      * [3.3 弗纳姆密码](#33-弗纳姆密码)
   * [4. 乘积密码](#4-乘积密码)
      * [4.1 迭代密码体制](#41-迭代密码体制)
      * [4.2 混淆和扩散](#42-混淆和扩散)
   * [5. 分组密码](#5-分组密码)
   * [6. DES](#6-des)
   * [7. AES](#7-aes)
   * [8. 流密码](#8-流密码)

<!-- Added by: anapodoton, at: 2019年12月 9日 星期一 14时57分00秒 CST -->

<!--te-->
# 1. 前言

对称密码概述：

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hiuyxx7fj30xc0ecgpq.jpg)

**P 明文空间 **

**C 密文空间 **

**K 密钥空间**

**E 加密算法** 

**D 解密算法** 

**(P, C, K, E, D)为密码体制** 



分为置换密码和替换密码。

二者的区别。

替换密码：其他字符替代明文字符。

置换密码：重新排列元素，不改变元素本身。

# 2. 置换密码

## 2.1 栅栏技术

**加密方法:**按照对角线顺序写出明文，并以行的顺序读出作为密文。

举例:

明文:meet after the toga party

栅栏数:2

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1h6m6oywoj311604kgnj.jpg)

**密文:**MEATRHTGPRYETFETEOAAT

**解密方法:** **将密文先分行，再按上下上下的顺序组成明文。** 

**密文：MEATRHTGPRYETFETEOAAT** 

**分行：MEATRHTGPRY**

**ETFETEOAAT** 

**明文：meet after the toga party** 

## 2.2 周期置换

**加密方法:** 将明文串P按固定长度m分组，然后对每组中的 子串按1，2，....m的某个置换重新排列得到密文。

 **加密密钥(置换)**

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1h6q1lgfuj30kg04kmy9.jpg)

**举例:** 

加密明文串:shesellsseashellsbytheseashore

 分块:**shesel** lsseas hellsb ythese ashore 

根据函数f重新排列
 **EESLSH** SALSES LSHBLE HSYEET HRAEOS 

生成密文:EESLSH|SALSES|LSHBLE|HSYEET|HRAEOS 



解密方法：

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1h6rlz19oj317o0iyk40.jpg)

## 2.3 列置换

**加密方法:** 

明文按行填写在一个矩形中，密文 则是以预定的顺序按列读取生成 

明文:shesellsseashellsbytheseashore 

密钥:351642 

密文:ESLHH LSBEE SLHYA EASSR HSETS SELEO。 

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1h6uymng7j30ju0aswhs.jpg)

**解密方法:**

将密文分组后按列的顺序排列，并根据密钥重新排列列的顺序。
密文:ESLHH LSBEE SLHYAEASSR HSETS SELEO
密钥:351642
明文:shesellsseashellsbytheseashore

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hh7g1bacj30j40cygnr.jpg)

## 2.4 多次列置换

单次列置换：**难以抗击字母频度分析**

多次列置换：用列置换法对明文进行加密，再对加密过的密文加密。

**明文:**meetafterthetogaparty

**密钥:**3412567

**密文:**PATTRTEERTGFHATAAOMEY

字母顺序更乱，增加破解难度、复杂度。

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hhjbyn3aj31ca09itg4.jpg)

# 3. 替换密码

替换密码是将明文字符替换成其他字母、数字或者符号。

## 3.1 凯撒密码

**数学表示:**

*Ci* *=(Pi* *+3)mod26
Pi* *=(Ci* *–3)mod26*

注意，不一定是3，可以是其他整数。

注意，可以通过统计规律进行破解，即每个字母出现的频率。

## 3.2 维吉尼亚密码

**如何抵抗频度分析?** 

明文密文的一一对应   -》明文密文的多个对应

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hicjnb9hj30qw0k47wh.jpg)

它是基于串的替换密码，密钥是由多于一个的字符所组成的串。

**数学表示:**

***C******i******=(P******i*** ***+k******i*** ***)mod26
P******i*** ***=(C******i*** ***–k******i*** ***)mod26***

m的含义是：m为密钥的长度，在下面的例子中m=3。

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hi5p6xs1j31hi0hyk5e.jpg)

**密钥空间是多大呢?** *26^m*

**被破译的原因?** 

 移位代换为基础的周期代换:密钥取自英文单词句子、统计特性与明文相同。

我们注意到密文第二次出现UPK和第一次出现UPK，中间差了21个字符，所以密钥的长度为21的因子，即3或者7。



## 3.3 弗纳姆密码

事实上是一次一密的思想。

原理：假定消息是长为 n的比特串，那么密钥也是长为 n 的比特串;

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20200216194515.png)

# 4. 乘积密码

如何设计安全强度更高的密码体制才能抵御住分析?

香农(Claude Shannon)提出的。

**原理**：依次使用两个或两个以上基本密码系统。所得结果的密码强度高于所有单个基本密码系统的强度。



**乘积密码的加密：**

明文空间P和密文空间C相同的密码体制。

R1=(P1，C1，K1，E1，D1) 

R2=(P2，C2，K2，E2，D2) 

乘积密码定义: R1×R2=(P，C，K1×K2，E，D) 

对于任意明文x∈P和密钥K=(K1，K2)，加密 变换为 ***E******K******(x)=E******K******2******(E******K******1******(x))*** 

**乘积密码的解密：**

对于任意密文y∈C和密钥 K=(K1，K2)，解密变换为 Dk *(y)*=Dk1(Dk2(y))



**乘积密码的代表：ADFGVX密码**

同时采用了替换和置换的方法，随机在6*6的表格中填入26个英文字母和0-9共10个数字。

首先进行替换，比如明文password中的p对应的行和列分别为FG。。。

明文:password 

密钥:computer 

中间结果:FG GV XG XG AF VD AG VF 

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1honm2kekj30w20dggrv.jpg)

然后把中间结果按照行的形式进行排列，最后对中间结果进行置换，密钥为computer，即密钥的顺序为14358726，则密文为：FA XV GV GF VD GF GG XA。

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/006tKfTcly1g1hqxqcgfvj30wy08o0ux.jpg)

## 4.1 迭代密码体制

密码体制的乘积运算满足结合律，明密文 空间相同的密码体制R1，R2，R3都有: (R**1*×*R**2**)*×*R**3**=R**1*×*(R**2*×*R**3**)* 

如果密码体制和自己乘积R×R，记为R^2,如果 做n重乘积，得到的密码体制记为Rn; 

如果R^2=R,那么R就是幂等的密码体制，不能 提高更多的安全性 。很显然，在幂等体制下，还是其本身，自然没有效果。比如置换。

若R是一个明文空间和密文空间相同的非幂等密码体制，多次迭代Rn的安全性可能会比R强。

**如何构造非幂等的密码体制?**

使用两个不同的密码体制做乘积，比如替换和置换。

## 4.2 混淆和扩散

**扩散的概念：**

明文每一位影响密文中的许多位，或者说让密文中的每一位受明文中的许多位的影响，将明文冗余度分散到密文中。进行扩散最简单的方法是置换（Permutation），即重新排列字符。

**影响：**

明文的统计特征消散在密文中，隐蔽明文字符出现次数的统计概率。

**混淆**

概念：让密文与密钥之间的统计关系变得尽可能复杂，使用复杂的非线性代替变换可以达到比较好的混淆效果。让明文和密文之间的关系复杂化，这样做是为了防止通过统计分析进而破译密码学。常用的方法是替换换(Substitution)。

意义：挫败推测出密钥的企图。

**混淆和扩散的实现：**

抵抗对手从密文的统计特性推测明文或密钥，现代分组密码的设计基础。



# 5. 分组密码

[分组密码](https://www.cnblogs.com/anapodoton/p/10613617.html)

# 6. DES

[DES算法](https://www.cnblogs.com/anapodoton/p/10615368.html)

# 7. AES

[AES算法](https://www.cnblogs.com/anapodoton/p/10615380.html)

# 8. 流密码

[流密码](https://www.cnblogs.com/anapodoton/p/10616101.html)













