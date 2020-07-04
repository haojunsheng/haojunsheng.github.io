---
layout: post
title: "区块链中的密码学系列之对称加密算法DES（六）"
date: 2019-03-09 
description: "2019-03-09-区块链中的密码学系列之对称加密算法DES（六）"
categories: 密码学
tag: [密码学,对称加密算法,DES]
---

<!--ts-->
   * [1. 前言](#1-前言)
   * [2. Feistel网络](#2-feistel网络)
   * [3. DES算法框架](#3-des算法框架)
   * [4. DES加密模块](#4-des加密模块)
      * [4.1 初始置换IP](#41-初始置换ip)
      * [4.2 DES的轮结构](#42-des的轮结构)
      * [4.3 子密钥生成算法](#43-子密钥生成算法)
   * [5. DES的加解密过程](#5-des的加解密过程)
   * [6. DES的安全性](#6-des的安全性)
   * [7. DES加密的一个例子](#7-des加密的一个例子)
   * [8. java版的DES算法](#8-java版的des算法)
   * [9. 3DES](#9-3des)
   * [10. 结束语](#10-结束语)

<!-- Added by: anapodoton, at: 2019年12月 9日 星期一 14时56分08秒 CST -->

<!--te-->
# 1. 前言

DES是一种数据加密标准（ Data Encryption Standard） , 有30多年历史，是一种对称密码算法，是第一个得到广泛应用的密码算法，是一种分组加密算法，输入的明文为64位，密钥为64位（实际上只有56位，原因是每隔7个比特设置一个奇偶校验位），生成的密文分组长度为64位。但是现在已经不再安全。

课件来自我们老师上课的PPT。

# 2. Feistel网络

我们可以参考这里，[Feistel讲解](https://www.cnblogs.com/anapodoton/p/10613617.html)

下面简单说下：

Feistel网络利用**乘积密码**实现关键密码模块。所谓乘积密码就是顺序或循环地执行两个或多个基本密码模块，提高密码强度。其思想就是Shannon提出的利用乘积密码

实现扩散和混淆。

**Feistel网络的加密结构**：将2w bit明文分成为左右两半、长为1 w bit的段，以L和R表示。然后进行n轮迭代，其第i轮迭代的输入为上一轮（第i-1轮）输出。

其中Ki是第i轮用的子密钥， f是密码设计者选取或设计密码轮函数。 称这种分组密码算法为Feistel网络（ Feistel Network） ， 它保证加密和解密可采用同一算法实施。

每次迭代称为一轮(Round)。 相应函数f 称作轮函数。

**Feistel网络的解密结构：**Feistel解密过程本质上与加密过程一样。密文作为输入，使用子密钥Ki的次序与加密过程相反， Kn,Kn-1,…,K1。保证了加密与解密过程可采用同一算法。

# 3. DES算法框架

![006tKfTcly1g1ic109lzcj31220jcanq/images/posts/crypto/006tKfTcly1g1ic109lzcj31220jcanq.jpg)

轮函数：

Li=Ri-1；

Ri=Li-1⊕f(Ri-1, Ki)。

<img src/images/posts/crypto/006tKfTcly1g1ic1f9pmlj30v70u0ard.jpg" alt="006tKfTcly1g1ic1f9pmlj30v70u0ard" style="zoom:33%;" />

# 4. DES加密模块

## 4.1 初始置换IP 

![006tKfTcly1g1ic2edyk4j31140nsnl1/images/posts/crypto/006tKfTcly1g1ic2edyk4j31140nsnl1.jpg)

## 4.2 DES的轮结构

![006tKfTcly1g1ic2xhmqoj311a0r8dw8/images/posts/crypto/006tKfTcly1g1ic2xhmqoj311a0r8dw8.jpg)



![006tKfTcly1g1ic3ednqgj30z80p0199/images/posts/crypto/006tKfTcly1g1ic3ednqgj30z80p0199.jpg)

**扩充变换**：扩充变换E的作用是将32比特的明文扩充为48比特。设m=m1m2…m31m32; c=c1c2…c47c48。满足E(m)=c， c1=m32,c2=m1,…,c7=m4,…,c48=m1。

![006tKfTcly1g1ic3q6trzj30oi0s8qjj/images/posts/crypto/006tKfTcly1g1ic3q6trzj30oi0s8qjj.jpg)

**8个S盒：**

​        每个S盒Sj将6比特输入缩减为4比特输出。 8个S盒总共将48比特输入缩减为32比特输出。

​        

​        每个S盒的输入为6比特串m=m1m2m3m4m5m6，输出为4比特串c=c1c2c3c4。



将m1m6, m2m3m4m5, c1c2c3c4都用10进制来表示，则在下表中位于m1m6 (0~3)行 m2m3m4m5 (0~15)列的数就是S盒的输出 c1c2c3c4(十进制转化成二进制)。

![006tKfTcly1g1ic5h9wasj31160bwk3r/images/posts/crypto/006tKfTcly1g1ic5h9wasj31160bwk3r.jpg)

例如若S1的输入为100110，则通过查表(S1)输出应该是表中的第2(10)行第3(0011)列的数字8，所以二进制输出为1000。

**置换P:**

置换P将32比特的输入，改变位置顺序：输出的第1位为输入的第16位，输出的第2位为输入的第7位， …，输出的第32位为输入的第25位。

<img src/images/posts/crypto/006tKfTcly1g1ic5q6u2nj30pu0r8467.jpg" alt="006tKfTcly1g1ic5q6u2nj30pu0r8467" style="zoom:33%;" />

## 4.3 子密钥生成算法

64位密钥（8位奇偶校验位，有效位为56位）经过置换选择1、循环左移、置换选择2等变换，产生出16个48位长的子密钥。

**置换选择1：**

64位密钥分为8个字节。每个字节的前7位是真正的密钥位，第8位是奇偶校验位。奇偶校验位可以从前7位密钥位计算得出，不是随机的，因而不起密钥的作用。因此，DES真正的密钥只有56位。

置换选择1的作用有两个：一是从64位密钥中去掉8个奇偶校验位；二是把其余56位密钥位打乱重排，且将前28位作为C0，后28位作为D0。

置换选择1的矩阵如下：

![006tKfTcly1g1ic71fo89j311g0cg0xj/images/posts/crypto/006tKfTcly1g1ic71fo89j311g0cg0xj.jpg)

**循环左移：**



​        每一次迭代，将Ci-1和Di-1按照一定的位数循环左移分别得到Ci和Di。

　　循环左移位数表如下：

![006tKfTcly1g1ic79g4y5j311605ywh2/images/posts/crypto/006tKfTcly1g1ic79g4y5j311605ywh2.jpg)



**置换选择2**        

​        将Ci和Di合并成一个56位的中间数据，置换选择2从中选择出一个48位的子密钥Ki。置换选择2的矩阵如下：

<img src/images/posts/crypto/006tKfTcly1g1ic7peyasj30pg12udo9.jpg" alt="006tKfTcly1g1ic7peyasj30pg12udo9" style="zoom:33%;" />

<img src/images/posts/crypto/006tKfTcly1g1ic81ghy0j310s0n8e0a.jpg" alt="006tKfTcly1g1ic81ghy0j310s0n8e0a" style="zoom:33%;" />

 缩减变换PC-1, PC-2 : PC-1将64比特串缩为56比特； PC-2将56比特长的串缩为48比特。两个变换的输出比特顺序如下：

<img src/images/posts/crypto/006tKfTcly1g1ic8qwme8j31220jkkhp.jpg" alt="006tKfTcly1g1ic8qwme8j31220jkkhp" style="zoom:33%;" />

# 5. DES的加解密过程

**DES的加密过程：**

1. 64位密钥经子密钥产生算法产生出16个48位子密钥：K1,K2,...,K16，分别供第1次，第2次，...，第16次加密迭代使用。

　　2. 64位明文首先经过初始置换IP，将数据打乱重新排列并分成左右两半，左边32位构成L0，右边32位构成R0。

　　3. 第i次加密迭代：由轮函数f实现子密钥Ki对Ri-1的加密，结果为32位的数据组f ( Ri-1 , Ki )。f ( Ri-1 , Ki )再与Li-1模2相加，又得到一个32位的数据组Li-1 ⊕ f ( Ri-1 , Ki )。以Li ⊕ f ( Ri-1 , Ki )作为下一次加密迭代的Ri，以Ri-1作为下一次加密迭代的Li ( i = 1,2,...,16)。

　　4. 按照上一步的规则进行16次加密迭代。

　　5. 第16次加密迭代结束后，以R16为左，L16为右，合并产生一个64位的数据组。再经过逆初始置换IP-1，将数据重新排列，便得到64位密文。

**DES的解密过程：**

1. 64位密钥经子密钥产生算法产生出16个48位子密钥：K1,K2,...,K16，分别供第1次，第2次，...，第16次解密迭代使用。
2. 64位密文首先经过初始置换IP，将数据打乱重新排列并分成左右两半，左边32位构成R16，右边32位构成L16。
3. 第17-i次解密迭代：由轮函数f实现子密钥Ki对Li的解密，结果为32位的数据组f ( Li , Ki )。f ( Li , Ki )再与Ri模2相加，又得到一个32位的数据组Ri ⊕ f ( Li , Ki )。以Ri ⊕ f ( Li , Ki )作为下一次解密迭代的Li-1，以Li作为下一次解密迭代的Li-1 ( i = 16,15,...,1)。
4. 按照上一步的规则进行16次解密迭代。
5. 第16次解密迭代结束后，以L0为左，R0为右，合并产生一个64位的数据组。再经过逆初始置换IP-1，将数据重新排列，便得到64位明文。

# 6. DES的安全性

DES算法中除了S盒是非线性变换外，其余变换均为线性变换，所以DES安全的关键是S盒（保密 ）。因为算法中使用了16次迭代，从而使得改变输入明文或密钥中的1位，密文都会发生大约32位的变化，具有良好的雪崩效应，大大提高了保密性。S盒用来提供混淆，使明文、密钥、密文之间的关系错综复杂，而P置换用来提供扩散，把S盒提供的混淆作用充分扩散开来。这样，S盒和P置换互相配合，形成了很强的抗差分攻击和抗线性攻击能力，其中抗差分攻击能力更强些。

# 7. DES加密的一个例子

取16进制明文X： 0123456789ABCDEF

密钥K为： 133457799BBCDFF1

去掉奇偶校验位以二进制形式表示的密钥是

00010010011010010101101111001001101101111011011111

111000

应用IP，我们得到：

L0=11001100000000001100110011111111

L1=R0=11110000101010101111000010101010

然后进行16轮加密。

最后对L16, R16使用IP-1得到密文： 85E813540F0AB405

# 8. java版的DES算法

DES工具类：

```java
public class DESUtil {
  //置换选择1矩阵
  static int[] replace1C = {
      57, 49, 41, 33, 25, 17,  9, 
       1, 58, 50, 42, 34, 26, 18, 
      10,  2, 59, 51, 43, 35, 27, 
      19, 11,  3, 60, 52, 44, 36
  };
  static int[] replace1D = {
      63, 55, 47, 39, 31, 23, 15, 
       7, 62, 54, 46, 38, 30, 22, 
      14,  6, 61, 53, 45, 37, 29, 
      21, 13,  5, 28, 20, 12,  4
  };

  //循环左移位数表
  static int[] moveNum = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

  //置换选择2矩阵
  static int[] replace2 = {
    14, 17, 11, 24,  1,  5, 
     3, 28, 15,  6, 21, 10, 
    23, 19, 12,  4, 26,  8, 
    16,  7, 27, 20, 13,  2, 
    41, 52, 31, 37, 47, 55, 
    30, 40, 51, 45, 33, 48, 
    44, 49, 39, 56, 34, 53, 
    46, 42, 50, 36, 29, 32
  };

  //初始置换矩阵
  static int[] IP = {
      58, 50, 42, 34, 26, 18, 10,  2, 
      60, 52, 44, 36, 28, 20, 12,  4, 
      62, 54, 46, 38, 30, 22, 14,  6, 
      64, 56, 48, 40, 32, 24, 16,  8, 
      57, 49, 41, 33, 25, 17,  9,  1, 
      59, 51, 43, 35, 27, 19, 11,  3, 
      61, 53, 45, 37, 29, 21, 13,  5, 
      63, 55, 47, 39, 31, 23, 15,  7
  };

  //选择运算矩阵
  static int[] E = {
      32,  1,  2,  3,  4,  5, 
       4,  5,  6,  7,  8,  9, 
       8,  9, 10, 11, 12, 13, 
      12, 13, 14, 15, 16, 17, 
      16, 17, 18, 19, 20, 21, 
      20, 21, 22, 23, 24, 25, 
      24, 25, 26, 27, 28, 29, 
      28, 29, 30, 31, 32,  1
  };

  //代替函数组
  static int[][][] S = {
      //S1
      {
        {14,  4, 13,  1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7}, 
        { 0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8}, 
        { 4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0}, 
        {15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13}
      }, 
      //S2
      {
        {15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10}, 
        { 3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5}, 
        { 0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15}, 
        {13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9}
      }, 
      //S3
      {
        {10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8}, 
        {13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1}, 
        {13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7}, 
        { 1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12}
      }, 
      //S4
      {
        { 7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15}, 
        {13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9}, 
        {10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4}, 
        { 3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14}
      }, 
      //S5
      {
        { 2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9}, 
                {14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6}, 
                { 4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14}, 
                {11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3}
      }, 
      //S6
      {
        {12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11}, 
        {10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8}, 
        { 9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6}, 
        { 4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13}
      }, 
      //S7
      {
        { 4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1}, 
        {13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6}, 
        { 1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2}, 
        { 6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12}
      }, 
      //S8
      {
        {13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7}, 
        { 1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2}, 
        { 7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8}, 
        { 2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11}
      }
  };

  //置换运算矩阵
  static int[] P = {
      16,  7, 20, 21, 
      29, 12, 28, 17, 
       1, 15, 23, 26, 
       5, 18, 31, 10, 
       2,  8, 24, 14, 
      32, 27,  3,  9, 
      19, 13, 30,  6, 
      22, 11,  4, 25
  };

  //逆初始置换矩阵
  static int[] rIP = {
      40,  8, 48, 16, 56, 24, 64, 32, 
      39,  7, 47, 15, 55, 23, 63, 31, 
      38,  6, 46, 14, 54, 22, 62, 30, 
      37,  5, 45, 13, 53, 21, 61, 29, 
      36,  4, 44, 12, 52, 20, 60, 28, 
      35,  3, 43, 11, 51, 19, 59, 27, 
      34,  2, 42, 10, 50, 18, 58, 26, 
      33,  1, 41,  9, 49, 17, 57, 25
  };

/***************************子密钥的产生**********************************************************************/
  /**
   * 子密钥的产生
   * @param sKey  64位密钥
   * @return      16个48位子密钥
   */
  static byte[][] generateKeys(byte[] sKey) {
    byte[] C = new byte[28];
    byte[] D = new byte[28];
    byte[][] keys = new byte[16][48];
    //置换选择1
    //一是从64位密钥中去掉8个奇偶校验位；二是把其余56位密钥位打乱重排
    for (int i = 0; i < 28; i++) {
      C[i] = sKey[replace1C[i] - 1];
      D[i] = sKey[replace1D[i] - 1];
    }

    for (int i = 0; i < 16; i++) {
      //循环左移
      C = RSHR(C, moveNum[i]);
      D = RSHR(D, moveNum[i]);
      //置换选择2
      for (int j = 0; j < 48; j++) {
        if (replace2[j] <= 28) 
          keys[i][j] = C[replace2[j] - 1];
        else 
          keys[i][j] = D[replace2[j] - 29];
      }
    }
    return keys;
  }
  /**
   * 循环左移
   * @param b  数组
   * @param n  位数
   * @return
   */
  static byte[] RSHR(byte[] b, int n) {
    String s = new String(b);
    s = (s + s.substring(0, n)).substring(n);
    return s.getBytes();
  }

/**********************初始置换IP**************************************************************************/
  /**
   * 初始置换IP
   * @param text  64位数据
   * @return
   */
  static byte[] IP(byte[] text) {
    byte[] newtext = new byte[64];
    for (int i = 0; i < 64; i++) 
      newtext[i] = text[IP[i] - 1];
    return newtext;
  }

/**********************轮函数**************************************************************************/
  /**
   * 轮函数
   * @param A  32位输入
   * @param K  48位子密钥
   * @return   32位输出
   */
  static byte[] f(byte[] A, byte[] K) {
    byte[] t = new byte[48];
    byte[] r = new byte[32];
    byte[] result = new byte[32];
    //选择运算E,扩充变换为48bit
    for (int i = 0; i < 48; i++) 
      t[i] = A[E[i] - 1];
    //模2相加，逐位异或，得到一个48位的结果
    for (int i = 0; i < 48; i++) 
      t[i] = (byte) (t[i] ^ K[i]);
    //代替函数组S， 8个S盒总共将48比特输入缩减为32比特输出。
    for (int i = 0, a = 0; i < 48; i += 6, a += 4) {
      int j = t[i] * 2 + t[i + 5];   //b1b6
      int k = t[i + 1] * 8 + t[i + 2] * 4 + t[i + 3] * 2 + t[i + 4];   //b2b3b4b5
      byte[] b = Integer.toBinaryString(S[i / 6][j][k] + 16).substring(1).getBytes();
      for (int n = 0; n < 4; n++) 
        r[a + n] = (byte) (b[n] - '0');
    }
    //置换运算P，重新打乱顺序输出
    for (int i = 0; i < 32; i++) 
      result[i] = r[P[i] - 1];
    return result;
  }
/**********************逆初始置换IP^-1**************************************************************************/
  /**
   * 逆初始置换IP^-1
   * @param text  64位数据
   * @return
   */
  static byte[] rIP(byte[] text) {
    byte[] newtext = new byte[64];
    for (int i = 0; i < 64; i++) 
      newtext[i] = text[rIP[i] - 1];
    return newtext;
  }
}
```



DES实现类：

```java
public class DES {
  /**
   * 加密
   * @param plaintext  64位明文
   * @param sKey       64位密钥
   * @return           64位密文
   */
  static byte[] encrypt(byte[] plaintext, byte[] sKey) {
    byte[][] L = new byte[17][32];
    byte[][] R = new byte[17][32];
    byte[] ciphertext = new byte[64];
    //子密钥的产生
    byte[][] K = DESUtil.generateKeys(sKey);
    //初始置换IP
    plaintext = DESUtil.IP(plaintext);
    //将明文分成左半部分L0和右半部分R0
    for (int i = 0; i < 32; i++) {
      L[0][i] = plaintext[i];
      R[0][i] = plaintext[i + 32];
    }
    //加密迭代
    for (int i = 1; i <= 16; i++) {
      L[i] = R[i - 1];
      R[i] = xor(L[i - 1], DESUtil.f(R[i - 1], K[i - 1]));
    }
    //以R16为左半部分，L16为右半部分合并
    for (int i = 0; i < 32; i++) {
      ciphertext[i] = R[16][i];
      ciphertext[i + 32] = L[16][i];
    }
    //逆初始置换IP^-1
    ciphertext = DESUtil.rIP(ciphertext);
    return ciphertext;
  }

  /**
   * 解密
   * @param ciphertext  64位密文
   * @param sKey        64位密钥
   * @return            64位明文
   */
  static byte[] decrypt(byte[] ciphertext, byte[] sKey) {
    byte[][] L = new byte[17][32];
    byte[][] R = new byte[17][32];
    byte[] plaintext = new byte[64];
    //子密钥的产生
    byte[][] K = DESUtil.generateKeys(sKey);
    //初始置换IP
    ciphertext = DESUtil.IP(ciphertext);
    //将密文分成左半部分R16和右半部分L16
    for (int i = 0; i < 32; i++) {
      R[16][i] = ciphertext[i];
      L[16][i] = ciphertext[i + 32];
    }
    //解密迭代
    for (int i = 16; i >= 1; i--) {
      L[i - 1] = xor(R[i], DESUtil.f(L[i], K[i - 1]));
      R[i - 1] = L[i];
      R[i] = xor(L[i - 1], DESUtil.f(R[i - 1], K[i - 1]));
    }
    //以L0为左半部分，R0为右半部分合并
    for (int i = 0; i < 32; i++) {
      plaintext[i] = L[0][i];
      plaintext[i + 32] = R[0][i];
    }
    //逆初始置换IP^-1
    plaintext = DESUtil.rIP(plaintext);
    return plaintext;
  }

  /**
   * 两数组异或
   * @param a
   * @param b
   * @return
   */
  static byte[] xor(byte[] a, byte[] b) {
    byte[] c = new byte[a.length];
    for (int i = 0; i < a.length; i++) 
      c[i] = (byte) (a[i] ^ b[i]);
    return c;
  }
}
```

DES测试：

```java

public class TestDES {
  public static void main(String[] args) {
    String strKey = "0011000100110010001100110011010000110101001101100011011100111000";
    byte[] sKey = strKey.getBytes();
    for (int i = 0; i < sKey.length; i++) 
      sKey[i] -= '0';
    System.out.print("密钥：");
    printByteArr(sKey);
    String strPlain = "0011000000110001001100100011001100110100001101010011011000110111";
    byte[] plaintext = strPlain.getBytes();
    for (int i = 0; i < plaintext.length; i++) 
      plaintext[i] -= '0';
    System.out.print("明文：");
    printByteArr(plaintext);
    byte[] ciphertext = DES.encrypt(plaintext, sKey);
    System.out.print("密文：");
    printByteArr(ciphertext);
    byte[] plainText = DES.decrypt(ciphertext, sKey);
    System.out.print("明文：");
    printByteArr(plainText);
  }

  static void printByteArr(byte[] b) {
    for (int i = 0; i < b.length; i++) {
      System.out.print(b[i]);
      if (i % 8 == 7) 
        System.out.print(" ");
    }
    System.out.println();
  }
}
```



测试结果：

![006tKfTcly1g1icb1lvgtj311k0707cd/images/posts/crypto/006tKfTcly1g1icb1lvgtj311k0707cd.jpg)

# 9. 3DES

为提高安全性， 并利用实现DES的现有软硬件， 将DES算法在多密钥下重复使用。

三重DES：

两个密钥的三重DES。C=Ek1[Dk2[Ek1[P]]]

三个密钥的三重DES。C=Ek3[Dk2[Ek1[P]]]

# 10. 结束语

我们学习了DES加密算法。DES作为对称加密，其实现还是比较复杂的。我们来简单回顾下，DES的加密过程。首先，我们需要生成16*48位的子密钥（子密钥的生成需要三步，即置换选择1，循环左移和置换选择2）。然后执行轮函数（分为四步，分别是扩充变换E，与密钥按位异或，S盒变换，P盒变换）。最后进行逆初始变换即可得到加密后的密文。

 解密与之类似。不再赘述。
