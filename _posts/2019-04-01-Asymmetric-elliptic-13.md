---
layout: post
title: "区块链中的密码学之非对称密码椭圆曲线（十三）"
date: 2019-04-01 
description: "2019-04-01-区块链中的密码学之非对称密码椭圆曲线（十三）"
categories: 密码学
tag: [密码学,非对称加密算法,ECC]
---
<!--ts-->
   * [1. 前言](#1-前言)
   * [2.  什么是椭圆曲线](#2--什么是椭圆曲线)
   * [3.  椭圆曲线如何进行运算](#3--椭圆曲线如何进行运算)
   * [4. GF(p)上的椭圆曲线](#4-gfp上的椭圆曲线)
      * [两解点相加](#两解点相加)
      * [求椭圆曲线的所有解点](#求椭圆曲线的所有解点)
   * [5. 椭圆曲线上Diffie-Hellman密钥交换](#5-椭圆曲线上diffie-hellman密钥交换)
   * [6. ELGamal型椭圆曲线密码](#6-elgamal型椭圆曲线密码)
      * [加密](#加密)
      * [解密](#解密)
      * [推荐椭圆曲线](#推荐椭圆曲线)
   * [7. 基于Java的椭圆曲线密码算法的实现](#7-基于java的椭圆曲线密码算法的实现)
   * [8. ECDSA的实现](#8-ecdsa的实现)

<!-- Added by: anapodoton, at: 2020年 7月 4日 星期六 20时00分10秒 CST -->

<!--te-->
# 1. 前言

在我们的印象中，密码学的研究都是通过各种运算实现加密解密的，属于代数里面的内容，而椭圆曲线属于几何学中的内容。两者的结合可谓是十分的神奇了。

下面我们来学习下椭圆曲线的具体实现。

# 2.  什么是椭圆曲线

欧式几何认为平行线不相交，而黎曼几何认为任意两条直线都相交于无穷远点，也即平行线是不存在的。

椭圆曲线的英文为 <u>Elliptic Curve</u>，ECC对RSA产生了巨大的挑战，<u>ECC的主要优点是可以使用比RSA更短的密钥获取相同水平的安全性，这样一来，加解密的时间就会缩短。</u>

另外我们回顾下之前学习的非对称加密算法，如Diffie-Hellman, ElGamal, Schnorr, DSA，这些都是建立在素数域GF(p)中的整数加法、乘法、幂和离散对数的运算性质上。我们可以迁移到ECC中来，所不同的是，运算的对象变为椭圆曲线上的点，比如在比特币中使用的签名算法就是ECDSA。

我们必须澄清的是，椭圆曲线的形状，并不是真的是椭圆形的，只是因为椭圆曲线的描述方程，类似于计算椭圆周长的方程。我们使用的椭圆曲线（韦尔斯特拉斯(Weierstrass)方程）的表达式如下：y^2+a1xy+a3y=x^3+a2x^2+a4x+a6。注意，该方程中的一系列系数可以定义在有理数域，实数域，复数域甚至可以是有限域上。

我们看一个实数域上的椭圆曲线：

![006tKfTcly1g1ks7ak402j30ns0ke786](/images/posts/crypto/006tKfTcly1g1ks7ak402j30ns0ke786.jpg)

# 3.  椭圆曲线如何进行运算

我们将尝试在椭圆曲线上进行各种运算的定义。

首先来回顾下，我们是如何定义实数域上的加法的。比如说为什么3+3=6,根据加法的定义，给定两个整数的输入，产生一个整数的输出，同理，我们是否可以给定椭圆曲线上的加法，即给定两个点A，B，得到另外一个点D呢？

加法：过曲线上的两点A、B画一条直线，找到直线与椭圆曲线的交点，交点关于x轴对称位置的点，定义为A+B，即为加法。如下图所示：A+B+C=0，即A+B=-C=D

![006tKfTcly1g1ks9qewgnj30ki0kotd5](/images/posts/crypto/006tKfTcly1g1ks9qewgnj30ki0kotd5.jpg)

如图所示，根据前面的描述，我们得到下面的结论：

计算点A和点B的和的时候，首先将点A和点B相连形成一条直线，那么这条直线必然与该椭圆曲线相交于某点点C，再取点C沿X轴对称的点便得到点D。

事情总不会这么顺利，我们来考虑下面几种特殊情况：值得注意的是，我们的讨论是在黎曼几何下面进行的，而不是在欧式几何中，他们当中的区别在于，前者认为不存在平行的线，即任意两条直线终将相交于无穷远处。无穷远点称为零元。

二倍运算：上述方法无法解释A + A，即两点重合的情况。因此在这种情况下，将椭圆曲线在A点的切线，与椭圆曲线的交点，交点关于x轴对称位置的点，定义为A + A，即2A，即为二倍运算。如下图所示：A + A = 2A = B

![006tKfTcly1g1ksljxlwqj30lm0fuq45](/images/posts/crypto/006tKfTcly1g1ksljxlwqj30lm0fuq45.jpg)



正负取反：将A关于x轴对称位置的点定义为-A，即椭圆曲线的正负取反运算。如下图所示：

![006tKfTcly1g1ksm8kpe4j30l60gg75d](/images/posts/crypto/006tKfTcly1g1ksm8kpe4j30l60gg75d.jpg)

无穷远点：如果将A与-A相加，过A与-A的直线平行于y轴，可以认为直线与椭圆曲线相交于无穷远点。如下图所示：

![006tKfTcly1g1ksmvmiwjj30lk0fagmf](/images/posts/crypto/006tKfTcly1g1ksmvmiwjj30lk0fagmf.jpg)



下面我们来推导下椭圆曲线上的一般加法公式：

下面对于一般的椭圆曲线方程，我们利用P, Q点的坐标(x1,y1)，(x2,y2)，给出求R=P+Q的坐标(x4,y4)的一般公式：

求椭圆曲线方程y^2+a1xy+a3y=x^3+a2x^2+a4x+a6上点P(x1,y1)， Q(x2,y2)的和R(x4,y4)的坐标。

解： 当 Q=O时， P+Q=P。当Q≠O时：

(1) 先求点-R(x3,y3) 。

因为P,Q,-R三点共线，故设共线方程为y=kx+b,其中

若P≠Q(P,Q两点不重合) 则直线斜率k=(y1-y2)/(x1-x2) ，当x1=x2，则P+Q=O；

若P=Q(P,Q两点重合) 则直线为椭圆曲线的切线，其斜率为k=-Fx(x,y)/Fy(x,y)

= (3x^2+2a2x+a4-a1y)/(2y+a1x+a3)，当2y+a1x+a3=0则P+Q=O 。

因此P,Q,-R三点的坐标值就是方程组：

y^2+a1xy+a3y=x^3+a2x^2+a4x+a6 -----------------[1]

y=(kx+b) -----------------[2]的解。

(2) 利用-R求R根据二次方程根与系数关系得：

y3+y4= -(a1x+a3)

故y4=-y3-(a1x+a3)=k(x1-x4)-y1-(a1x4+a3); 求出点R的纵坐标。

因为-R与R的连线平行于y轴，于是有x4=x3= k2+ka1-a2-x1-x2; --------

求出点R的横坐标。

因为y3, y4为x=x4时方程y^2+a1xy+a3y=x^3+a2x^2+a4x+a6的解，该等式化为一般方程y^2+(a1x+a3)y-(x^3+a2x^2+a4x+a6)=0即P(x1, y1)+Q(x2, y2) = R(x4, y4) 的横左边与纵坐标分别为： 

**x4=k2+ka1-a2-x1-x2**

**y4=k(x1-x4)-y1-a1x4-a3**

Δ 当P≠Q (P,Q两点不重合) ，则直线斜率k=(y1-y2)/(x1-x2) ，若x1=x2，

则P+Q=O；

Δ 当P=Q (P,Q两点重合) ，则直线为椭圆曲线的切线，其斜率为k=-

Fx(x,y)/Fy(x,y)= (3x2+2a2x+a4-a1y)/(2y+a1x+a3)，若2y+a1x+a3=0则P+Q=O 。

![006tKfTcly1g1kscswtl7j30nw0roawu](/images/posts/crypto/006tKfTcly1g1kscswtl7j30nw0roawu.jpg)

综上，定义了A+B、2A运算，因此给定椭圆曲线的某一点G，可以求出2G、3G（即G + 2G）、4G......。即：当给定G点时，已知x，求xG点并不困难。反之，已知xG点，求x则非常困难。此即为椭圆曲线加密算法背后的数学原理。

上面的讨论全是在实数域上进行的，下面我们扩展到有限域上的椭圆曲线。

有限域上的运算：

- **GF(p)的加法(a+b)是模p加法**
- **GF(p)的乘法(a×b)是模p乘法**
- **GF(p)的除法(a÷b)模p除法a乘以b模p的逆**



**椭圆曲线上的标量乘法**

进一步，我们还可以定义在椭圆曲线上的标量乘法，如下所示：

A * 2 = A + A;

A * 3 = A + A + A;

...

如果将点和点之间的加法类比成整数之间的乘法，那么点的标量乘法不就相当于整数上的幂模运算吗？反过来，点之间的除法运算不就相当于证书上的离散对数运算吗？

![006tKfTcly1g1ku5tbtt7j30zu076762](/images/posts/crypto/006tKfTcly1g1ku5tbtt7j30zu076762.jpg)

# 4. GF(p)上的椭圆曲线

设p是大于3的素数，且4a^3+27b^2≠0(mod p)，称曲线y^2=x^3+ax+b（a,b∈GF(p)）为GF(p)上的椭圆曲线。

由椭圆曲线方程可得到一同余方程：y^2=x^3+ax+b(mod p)（a,b∈GF(p)）

其解为一个二元组(x,y)，其中x,y∈GF(p)，表示椭圆曲线上的一个点，称为该椭圆曲线上的解点。

## 两解点相加

设P(x1,y1)和Q(x2,y2)是解点，R(x3,y3)=P(x1,y1)+Q(x2,y2)：

　　1.若P为无穷点，即P=O，此时R=P+Q=Q；若Q为无穷点，即Q=O，此时R=P+Q=P；若P和Q都为无穷点，即P=Q=O，则R=P+Q=O。

　　2.若x1=x2且y1=y2，即P=Q，此时R=P+Q=2P，其中

![006tKfTcly1g1kt7lf4scj30ag06ijrp](/images/posts/crypto/006tKfTcly1g1kt7lf4scj30ag06ijrp.jpg)

　　3.若x1=x2而y1=-y2，此时称Q点为P点的逆，记为P=-Q，且R=P+Q=O。

　　4.除上述特殊情况之外的一般情况，即P≠±Q时，R=P+Q，其中

 ![006tKfTcly1g1kt7u5kicj30ak05yzkm](/images/posts/crypto/006tKfTcly1g1kt7u5kicj30ak05yzkm.jpg)



集合E={所有的解点,无穷点O}和加法运算构成加法交换群。设G(G≠O，即G为一个解点)为一个加法群的生成元，则使得nG=G+G+...+G=O的倍数n为该加法群的阶。加法群的阶整除集合E的阶，即n | |E|。

## 求椭圆曲线的所有解点

当p较小，即GF(p)较小时，可以利用穷举的方法根据同余方程y^2=x63+ax+b(mod p)（a,b∈GF(p)）求出所有解点。

　　具体方法为：求出x取0~p-1，x3+ax+b(mod p)的结果是否为模p的二次剩余。如果是，则一个x值可得到两个对应的y值，也就得到互逆的两个解点。

　　e.m.取p=11，椭圆曲线y^2=x^3+x+6

![006tKfTcly1g1ktmenl4zj30qq0taq53](/images/posts/crypto/006tKfTcly1g1ktmenl4zj30qq0taq53.jpg)

由此表得到所有的解点：(2,4)、(2,7)、(3,5)、(3,6)、(5,2)、(5,9)、(7,2)、(7,9)、(8,3)、(8,8)、(10,2)、(10,9)，再加上无穷点O共13个点的集合E加上加法运算就构成一个加法交换群。

因为集合E的阶|E|=13为素数，所以该加法群的阶为13。

取G=(2,7)为生成元，G=(2,7)，2G=(5,2)，3G=(8,3)，4G=(10,2)，5G=(3,6)，6G=(7,9)，7G=(7,2)，8G=(3,5)，9G=(10,9)，10G=(8,8)，11G=(5,9)，12G=(2,4)，最终得到13G=O，所以加法群的阶为13。



根据椭圆曲线的一般加法公式，对于GF(p^r)(p>3)上的椭圆曲线方程y^2=x^3+ax+b，给出Ep(a,b)上的加法公式: 

设P,Q∈Ep(a,b)，则:

1. P+O=P;
2. 如果P=(x,y)，那么(x,y)+(x,-y)=O，即(x,-y)是P的加法逆元，表示为-P。
3. 设P=(x1,y1), Q=(x2,y2), P≠-Q，则P+Q=(x4,y4),可由以下规则确定 x4=k^2+-x1-x2 modp,y =k(x -x )-y modp 

其中，![006tKfTcly1g1kub82jevj308u05ymxd](/images/posts/crypto/006tKfTcly1g1kub82jevj308u05ymxd.jpg)

# 5. 椭圆曲线上Diffie-Hellman密钥交换

首先取一素数p≈2180，以及参数a, b，则椭圆曲线上的点构成Abel群Ep(a, b)。

取Ep(a, b)上的一个生成元G(x1, y1)，要求G的阶是一个非常大的数，G的阶是满足nG=O的最小正整数。

Ep(a, b)和G作为公钥体制的公开密钥参数，对外公布。



A选择一小于n的整数nA作为私钥，由PA=nAG产生Ep(a,b) 上的一点作为公钥。

 B类似地选取自己的私钥nB，并计算自己的公钥PB=nBG。

 A可以获得B的公钥PB；
 B可以获得A的公钥PA ；

A计算: K=nA× PB= nAnBG ；

B计算: K=nB× PA= nAnBG 。

至此，A和B共同拥有密钥K= nAnBG。攻击者如果想获得密钥K，他就必须由PA和G求出nA，或者由PB和G
求出nB，而这等价于求椭圆曲线上的离散对数问题ECDLP，因此是不可行的。

**举例**：

选择p=211，E211(0,-4)，即椭圆曲线为y^2≡x^3-4mod 211;
G=(2,2)是E211(0,-4)上的一个生成元，阶n=241，241G=O;
A取私钥为nA=121，可计算公钥PA=121 ×(2,2)=(115,48);
B取私钥为nB=203，可计算公钥PB=203 ×(2,2)=(130,203);
A计算共享密钥:121×PB=121× (130,203)=(161,169);
B计算共享密钥:203×PA=203× (115, 48)=(161,169);

可见，此时A和B共享密钥是一对数据。如果在后续采用单钥体制加密时，可以简单地取其中的一个坐标，比如x坐标，或x坐标的一个简单函数作为共享的密钥进行加密/解密运算。



# 6. ELGamal型椭圆曲线密码

1.选择一个素数p，从而确定有限域GF(p)，将p公开。

2.选择元素a,b∈GF(p)，从而确定一条GF(p)上的椭圆曲线，确定加法交换群E，将a和b公开。

3.选择一个大素数n，并确定一个阶为n的基点G(x,y)，将n和G(x,y)公开。

4.余因子h=|E|/n，将h公开。

5.随机选择一个整数d(0<d<n)作为私钥保密。

6.定义Q=dG作为公钥公开。

## 加密

待发送消息Pm，任意用户B随机选择临时秘密参数k∈Zn，按照下列运算计算密文(C1, C2) :

C1=kG
C2=Pm+kPA

## 解密

为了解密(C1, C2)，Alice计算 Pm=C2-nAC1 

解密可行性:Pm=C2-nAC1=C2-nAkP=Pm+knAP-nAkP 

**例子**

取公开参数p=751, Ep(-1,188)，即椭圆曲线为y^2=x^3- x+188。选取基点为G=(0, 376)，A的公钥为PA=(201, 5)。 

假设消息m嵌入到椭圆曲线上的点为Pm=(562, 201)。 加密者B选取随机数k=386，计算密文
 C1=kG=386(0, 376)=(676, 558)，
 C2=Pm+kPA =(562, 201)+386(201, 5)=(385, 328)。 

## 推荐椭圆曲线

NIST向社会推荐了5条素域GF(p)上随机选取的椭圆曲线：

**P-192**

　　p=2192-264-1

　　a=-3

　　b=64210519 E59C80E7 0FA7E9AB 72243049 FEB8DEEC C146B9B1

　　x=188DA80E B03090F6 7CBf20EB 43A18800 F4FF0AFD 82FF1012

　　y=07192B95 FFC8DA78 631011ED 6B24CDD5 73F977A1 1E794811

　　n=FFFFFFFF FFFFFFFF FFFFFFFF 99DEF836 146BC9B1 B4D22831

　　h=1

**P-224**

　　p=2224-296-1

　　a=-3

　　b=B4050A85 0C04B3AB F5413256 5044B0B7 D7BFD8BA 270B3943 2355FFB4

　　x=B70E0CBD 6BB4BF7F 321390B9 4A03C1D3 56C21122 343280D6 115C1D21

　　y=BD376388 B5F723FB 4C22DFE6 CD4375A0 5A074764 44D58199 85007E34

　　n=FFFFFFFF FFFFFFFF FFFFFFFF FFFF16A2 E0B8F03E 13DD2945 5C5C2A3D

　　h=1

**P-256**

　　p=2256-2224+2192+296-1

　　a=-3

　　b=5AC635D8 AA3A93E7 B3EBBD55 769886BC 651D06B0 CC53B0F6 3BCE3C3E 27D2604B

　　x=6B17D1F2 E12C4247 F8BCE6E5 63A440F2 77037D81 2DEB33A0 F4A13945 D898C296

　　y=4FE342E2 FE1A7F9B 8EE7EB4A 7C0F9E16 2BCE3357 6B315ECE CBB64068 37BF51F5

　　n=FFFFFFFF 00000000 FFFFFFFF FFFFFFFF BCE6FAAD A7179E84 F3B9CAC2 FC632551

　　h=1

**P-384**

　　p=2384-2128-296+232-1

　　a=-3

　　b=B3312FA7 E23EE7E4 988E056B E3F82D19 181D9C6E FE814112 0314088F 5013875A C656398D 8A2ED19D 2A85C8ED D3EC2AEF

　　x=AA87CA22 BE8B0537 8EB1C71E F320AD74 6E1D3B62 8BA79B98 59F741E0 82542A38 5502F25D BF55296C 3A545E38 72760AB7

　　y=3617DE4A 96262C6F 5D9E98BF 9292DC29 F8F41DBD 289A147C E9DA3113 B5F0B8C0 0A60B1CE 1D7E819D 7A431D7C 90EA0E5F

　　n=FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF C7634D81 F4372DDF 581A0DB2 48B0A77A ECEC196A CCC52973

　　h=1

**P-521**

　　p=2521-1

　　a=-3

　　b=00000051 953EB961 8E1C9A1F 929A21A0 B68540EE A2DA725B 99B315F3 B8B48991 8EF109E1 56193951 EC7E937B 1652C0BD 3BB1BF07 3573DF88 3D2C34F1 EF451FD4 6B503F00

　　x=000000C6 858E06B7 0404E9CD 9E3ECB66 2395B442 9C648139 053FB521 F828AF60 6B4D3DBA A14B5E77 EFE75928 FE1DC127 A2FFA8DE 3348B3C1 856A429B F97E7E31 C2E5BD66

　　y=00000118 39296A78 9A3BC004 5C8A5FB4 2C7D1BD9 98F54449 579B4468 17AFBD17 273E662C 97EE7299 5EF42640 C550B901 3FAD0761 353C7086 A272C240 88BE9476 9FD16650

　　n=000001FF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF 51868783 BF2F966B 7FCC0148 F709A5D0 3BB5C9B8 899C47AE BB6FB71E 91386409

　　h=1

# 7. 基于Java的椭圆曲线密码算法的实现

通常将Fp上的一条椭圆曲线描述为T=(p,a,b,G,n,h),p、a、b确定一条椭圆曲线（p为质数，(mod p)运算）G为基点，n为点G的阶，h是椭圆曲线上所有点的个数m与n相除的商的整数部分。



ECPoint:

```java
import java.math.BigInteger;

public class ECPoint {
	BigInteger x;
	BigInteger y;
public ECPoint() {
	x = null;
	y = null;
}

public ECPoint(BigInteger x, BigInteger y) {
	this.x = x;
	this.y = y;
}

@Override
public String toString() {
	if (isO()) 
		return "O";
	return "(" + x.toString(16) + ", " + y.toString(16) + ")";
}

boolean isO() {
	if (x == null && y == null) 
		return true;
	return false;
}
}
```
ECC_p.java



```java
import java.math.BigInteger;
import java.util.Random;

public class ECC_p {
	public static BigInteger p, a, b, x, y, n, h;
	static EC_p ec;
	public static ECPoint G, Q;
	private static BigInteger d;
public ECC_p() {
	int k = new Random().nextInt(5);
	switch (k) {
		case 0 : 
			init(192);
			break;
		case 1 : 
			init(244);
			break;
		case 2 : 
			init(256);
			break;
		case 3 : 
			init(384);
			break;
		case 4 : 
			init(521);
			break;
	}
}

public ECC_p(int k) {
	init(k);
}

static void init(int k) {
	switch (k) {
		case 192 : 
			p = new BigInteger("2").pow(192).subtract(new BigInteger("2").pow(64)).subtract(new BigInteger("1"));
			a = new BigInteger("-3");
			b = new BigInteger("64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1", 16);
			x = new BigInteger("188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012", 16);
			y = new BigInteger("07192b95ffc8da78631011ed6b24cdd573f977a11e794811", 16);
			n = new BigInteger("ffffffffffffffffffffffff99def836146bc9b1b4d22831", 16);
			h = new BigInteger("1");
			break;
		case 224 : 
			p = new BigInteger("2").pow(224).subtract(new BigInteger("2").pow(96)).subtract(new BigInteger("1"));
			a = new BigInteger("-3");
			b = new BigInteger("b4050a850c04b3abf54132565044b0b7d7bfd8ba270b39432355ffb4", 16);
			x = new BigInteger("b70e0cbd6bb4bf7f321390b94a03c1d356c21122343280d6115c1d21", 16);
			y = new BigInteger("bd376388b5f723fb4c22dfe6cd4375a05a07476444d5819985007e34", 16);
			n = new BigInteger("ffffffffffffffffffffffffffff16a2e0b8f03e13dd29455c5c2a3d", 16);
			h = new BigInteger("1");
			break;
		case 256 : 
			p = new BigInteger("2").pow(256).subtract(new BigInteger("2").pow(224)).add(new BigInteger("2").pow(192)).add(new BigInteger("2").pow(96)).subtract(new BigInteger("1"));
			a = new BigInteger("-3");
			b = new BigInteger("5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b", 16);
			x = new BigInteger("6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296", 16);
			y = new BigInteger("4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5", 16);
			n = new BigInteger("ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551", 16);
			h = new BigInteger("1");
			break;
		case 384 : 
			p = new BigInteger("2").pow(384).subtract(new BigInteger("2").pow(128)).subtract(new BigInteger("2").pow(96)).add(new BigInteger("2").pow(32)).subtract(new BigInteger("1"));
			a = new BigInteger("-3");
			b = new BigInteger("b3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef", 16);
			x = new BigInteger("aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7", 16);
			y = new BigInteger("3617de4a96262c6f5d9e98bf9292dc29f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f", 16);
			n = new BigInteger("ffffffffffffffffffffffffffffffffffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973", 16);
			h = new BigInteger("1");
			break;
		case 521 : 
			p = new BigInteger("2").pow(521).subtract(new BigInteger("1"));
			a = new BigInteger("-3");
			b = new BigInteger("00000051953eb9618e1c9a1f929a21a0b68540eea2da725b99b315f3b8b489918ef109e156193951ec7e937b1652c0bd3bb1bf073573df883d2c34f1ef451fd46b503f00", 16);
			x = new BigInteger("000000c6858e06b70404e9cd9e3ecb662395b4429c648139053fb521f828af606b4d3dbaa14b5e77efe75928fe1dc127a2ffa8de3348b3c1856a429bf97e7e31c2e5bd66", 16);
			y = new BigInteger("0000011839296a789a3bc0045c8a5fb42c7d1bd998f54449579b446817afbd17273e662c97ee72995ef42640c550b9013fad0761353c7086a272c24088be94769fd16650", 16);
			n = new BigInteger("000001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff51868783bf2f966b7fcc0148f709a5d03bb5c9b8899c47aebb6fb71e91386409", 16);
			h = new BigInteger("1");
			break;
	}
	ec = new EC_p(p, a, b);
	G = new ECPoint(x, y);
	d = new BigInteger(n.bitLength(), new Random());
	Q = ec.multiply(G, d);
}

/**
 * 加密
 * @param M
 * @return
 */
BigInteger[] encrypt(BigInteger M) {
	BigInteger k;
	ECPoint X1, X2;
	do {
		k = new BigInteger(n.bitLength(), new Random());
	} while ((X2 = ec.multiply(Q, k)).x == null);
	X1 = ec.multiply(G, k);
	BigInteger[] C = new BigInteger[3];
	C[0] = X1.x;
	C[1] = X1.y;
	C[2] = M.multiply(X2.x).mod(n);
	return C;
}

/**
 * 加密
 * @param M
 * @param k
 * @return
 */
BigInteger[] encrypt(BigInteger M, BigInteger k) {
	ECPoint X1 = ec.multiply(G, k);
	ECPoint X2 = ec.multiply(Q, k);
	BigInteger[] C = new BigInteger[3];
	C[0] = X1.x;
	C[1] = X1.y;
	C[2] = M.multiply(X2.x).mod(n);
	return C;
}

/**
 * 解密
 * @param C
 * @return
 */
BigInteger decrypt(BigInteger[] C) {
	ECPoint X1 = new ECPoint(C[0], C[1]);
	ECPoint X2 = ec.multiply(X1, d);
	BigInteger M = C[2].multiply(X2.x.modPow(new BigInteger("-1"), n)).mod(n);
	return M;
}
}
```
EC_p.java



```java
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

public class EC_p {
	BigInteger p;
	BigInteger a;
	BigInteger b;
public EC_p(BigInteger p, BigInteger a, BigInteger b) {
	this.p = p;
	this.a = a;
	this.b = b;
}

@Override
public String toString() {
	return "y²=x³+" + a.toString(16) +"x+" + b.toString(16) + "(mod " + p.toString(16) + ")";
}

/**
 * 两解点相加
 * @param p1
 * @param p2
 * @return
 */
ECPoint add(ECPoint p1, ECPoint p2) {
	if (p1.isO()) return p2;
	if (p2.isO()) return p1;
	ECPoint p3 = new ECPoint();
	BigInteger lambda;
	if (p1.x.compareTo(p2.x) == 0) {
		if (p1.y.compareTo(p2.y) == 0) {
			lambda = new BigInteger("3").multiply(p1.x.pow(2)).add(a).multiply(new BigInteger("2").multiply(p1.y).modPow(new BigInteger("-1"), p)).mod(p);
			p3.x = lambda.pow(2).subtract(new BigInteger("2").multiply(p1.x)).mod(p);
			p3.y = lambda.multiply(p1.x.subtract(p3.x)).subtract(p1.y).mod(p);
			return p3;
		}
		if (p1.y.compareTo(p.subtract(p2.y)) == 0) 
			return p3;
	}
	lambda = p2.y.subtract(p1.y).multiply(p2.x.subtract(p1.x).modPow(new BigInteger("-1"), p)).mod(p);
	p3.x = lambda.pow(2).subtract(p1.x).subtract(p2.x).mod(p);
	p3.y = lambda.multiply(p1.x.subtract(p3.x)).subtract(p1.y).mod(p);
	return p3;
}

/**
 * 倍乘
 * @param p
 * @param n
 * @return  np
 */
ECPoint multiply(ECPoint p, BigInteger n) {
	ECPoint q = add(p, new ECPoint());
	ECPoint r = new ECPoint();
	do {
		if (n.and(new BigInteger("1")).intValue() == 1) 
			r = add(r, q);
		q = add(q, q);
		n = n.shiftRight(1);
	} while (n.intValue() != 0);
	return r;
}

/**
 * 求阶
 * @param p  生成元
 * @return   p对应的阶
 */
BigInteger o(ECPoint p) {
	BigInteger r = new BigInteger("1");
	while (! p.isO()) {
		r = r.add(new BigInteger("1"));
		p = multiply(p, r);
	}
	return r;
}

/**
 * 求所有解点
 * @return
 */
List<ECPoint> solutionPoints() {
	List<ECPoint> r = new ArrayList<ECPoint>();
	List<BigInteger> l = new ArrayList<BigInteger>();
	for (BigInteger y = new BigInteger("1"); y.compareTo(p.divide(new BigInteger("2"))) != 1; y = y.add(new BigInteger("1"))) 
		l.add(y.modPow(new BigInteger("2"), p));
	for (BigInteger x = new BigInteger("0"); x.compareTo(p) == -1; x = x.add(new BigInteger("1"))) {
		BigInteger t = x.pow(3).add(a.multiply(x)).add(b).mod(p);
		if (isExist(t, l) != -1) {
			BigInteger y = new BigInteger(isExist(t, l) + "");
			r.add(new ECPoint(x, y));
			r.add(new ECPoint(x, p.subtract(y)));
		}
	}
	r.add(new ECPoint());
	return r;
}
static int isExist(BigInteger b, List<BigInteger> l) {
	for (int i = 0; i < l.size(); i++) 
		if (l.get(i).compareTo(b) == 0) return (i + 1);
	return -1;
}
}
```
TestECC.java

```java
import java.math.BigInteger;

public class TestECC {
	public static void main(String[] args) {
		BigInteger M = new BigInteger("1234567890abcdef", 16);
		System.out.println("明文：M=" + M.toString(16));
		ECC_p ecc;
		BigInteger k = new BigInteger("abcdef", 16);
		BigInteger[] C;
		ECPoint X1;
	System.out.println("P-192");
	ecc = new ECC_p(192);
	C = ecc.encrypt(M, k);
	X1 = new ECPoint(C[0], C[1]);
	System.out.println("密文：(" + X1 + ", " + C[2].toString(16) +")");
	M = ecc.decrypt(C);
	System.out.println("明文：M=" + M.toString(16));

	System.out.println("P-224");
	ecc = new ECC_p(224);
	C = ecc.encrypt(M, k);
	X1 = new ECPoint(C[0], C[1]);
	System.out.println("密文：(" + X1 + ", " + C[2].toString(16) +")");
	M = ecc.decrypt(C);
	System.out.println("明文：M=" + M.toString(16));

	System.out.println("P-256");
	ecc = new ECC_p(256);
	C = ecc.encrypt(M, k);
	X1 = new ECPoint(C[0], C[1]);
	System.out.println("密文：(" + X1 + ", " + C[2].toString(16) +")");
	M = ecc.decrypt(C);
	System.out.println("明文：M=" + M.toString(16));

	System.out.println("P-384");
	ecc = new ECC_p(384);
	C = ecc.encrypt(M, k);
	X1 = new ECPoint(C[0], C[1]);
	System.out.println("密文：(" + X1 + ", " + C[2].toString(16) +")");
	M = ecc.decrypt(C);
	System.out.println("明文：M=" + M.toString(16));

	System.out.println("P-521");
	ecc = new ECC_p(521);
	C = ecc.encrypt(M, k);
	X1 = new ECPoint(C[0], C[1]);
	System.out.println("密文：(" + X1 + ", " + C[2].toString(16) +")");
	M = ecc.decrypt(C);
	System.out.println("明文：M=" + M.toString(16));
}
}
```
![006tKfTcly1g1kvy93rspj30v80nkn2r](/images/posts/crypto/006tKfTcly1g1kvy93rspj30v80nkn2r.jpg)

 

# 8. ECDSA的实现







