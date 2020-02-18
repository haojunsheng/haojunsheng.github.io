---
layout: post
title: "区块链中的密码学系列之对称加密算法流密码（八）"
date: 2019-03-13 
description: "2019-03-13-区块链中的密码学系列之对称加密算法流密码（八）"
categories: 密码学
tag: 密码学
---

<!--ts-->
   * [1. 前言](#1-前言)
   * [2. 流密码的基本原理](#2-流密码的基本原理)
   * [3. <strong>密钥流生成器</strong>](#3-密钥流生成器)

<!-- Added by: anapodoton, at: 2019年12月 9日 星期一 14时54分57秒 CST -->

<!--te-->
# 1. 前言



# 2. 流密码的基本原理

**流密码**：也称序列密码 (Stream Cipher) ,是指明文消息按**字符(如二元数字)逐位地、对应地加密**的一类密码算法。

![006tKfTcly1g1il51nd1aj31fe08q421](/images/posts/crypto/006tKfTcly1g1il51nd1aj31fe08q421.jpg)

![006tKfTcly1g1il7wrl47j30os06ajt5](/images/posts/crypto/006tKfTcly1g1il7wrl47j30os06ajt5.jpg)



流密码的强度依赖于密钥序列，什么样的密钥序列是安全的？

随机，周期性大，统计特性良好。

随机数的性质：

![006tKfTcly1g1ilcerz4sj30ra0n0dp8](/images/posts/crypto/006tKfTcly1g1ilcerz4sj30ra0n0dp8.jpg)



**伪随机序列：**

流密码的密钥序列应该是变长、随机、 不可预测的。 

关键技术:通信双方的精确同步。

**伪随机数生成器：**

![006tKfTcly1g1ilesge66j30ow0e6wib](/images/posts/crypto/006tKfTcly1g1ilesge66j30ow0e6wib.jpg)

# 3. **密钥流生成器**

**1.伪随机数生成器(prng)：**

线性同余法伪随机数发生器;
线性反馈移位寄存器。

**2.线性同余法**

要生成的伪随机数列R1,R2,R3.... 

R1=(A×种子+C) mod M 

A、C、M是常量， A和C小于M

 R2=(A×R1+C) mod M 

......... Rn+1=(A×Rn+C) mod M 

**3. 线性同余法伪随机数发生器**

![006tKfTcly1g1ilmxjfi5j30ti0dwju7](/images/posts/crypto/006tKfTcly1g1ilmxjfi5j30ti0dwju7.jpg)



例:A=3,C=0,M=7，种子为6 

伪随机数:451326...451326 

R1=4,R2=5,R3=1,R4=3，周期6 谨慎选择A、C、M的值 

**4. 线性反馈移位寄存器**

易于硬件实现，速度快，典型应用:A5,GSM语音加密标准。

![006tKfTcly1g1ilpa97enj30r607o76r](/images/posts/crypto/006tKfTcly1g1ilpa97enj30r607o76r.jpg)



![006tKfTcly1g1ilpuk888j30v2092wik](/images/posts/crypto/006tKfTcly1g1ilpuk888j30v2092wik.jpg)



反馈函数f(a1,a2,...an)为n元布尔函数，自变量和因变量只能取0，1值

 f(a1,a2,...an)=cna1⊕ cn-1a2⊕ ...⊕ c1an 

c1，c2，...cn为反馈系数,取值0、1，表示开关断开和闭合 

若当前状态Si=(ai,ai+1,...ai+n-1) 

则:an+i=cnai⊕ cn-1ai+1⊕ ...⊕ c1an+i-1，i=1，2，...，移位寄存器的输入 Si+1=(ai+1,ai+2,...ai+n) 

**流密码优点：**

实现简单；

加解密速度快；

 没有或者有限的错误传播；

典型的应用领域包括无线通信、外交通信







