---
layout: post
title: "区块链中的密码学系列之数字签名方案（十二）"
date: 2019-03-25 
description: "2019-03-25-区块链中的密码学系列之数字签名方案（十二）"
categories: 密码学
tag: 密码学
---
<!--ts-->
Table of Contents
=================

   * [1. 前言](#1-前言)
   * [2. DSA](#2-dsa)
   * [3. ECDSA](#3-ecdsa)
   * [4. HMAC](#4-hmac)
   * [5. 盲签名](#5-盲签名)
   * [6. 多重签名](#6-多重签名)
   * [7. 群签名](#7-群签名)
   * [8. 环签名](#8-环签名)
<!--te-->
# 1. 前言

消息认证码和数字签名用来对消息的摘要进行加密，用于消息防篡改和身份证明。

消息认证码（Hash-based Message Authentication Code）是对称加密，保护消息的完整性。基本过程是对于某个消息使用对称密钥和hash算法进行加密处理，得到HMAC值，用于证明自己知道对称密钥，且消息的内容未被篡改。

HMAC(K,H,Message)由k,h,message组成，缺点是需要提前共享密钥。



然后我们引入了不需要提前共享密钥的数字签名技术。类似在纸质合同上签名确认合同内容，数字签名用于证实某数字内容的完整性（ integrity）和来源（ 或不可抵赖，non-repudiation）。
一个典型的场景是，A 要发给 B 一个文件（ 一份信息） ，B 如何获知所得到的文件即为 A 发出的原始版本？A 先对文件进行摘要，然后用自己的私钥进行加密，将文件和加密串都发给B。B 收到文件和加密串后，用 A 的公钥来解密加密串，得到原始的数字摘要，跟对文件进行摘要后的结果进行比对。如果一致，说明该文件确实是 A 发过来的，并且文件内容没有被修改过。

我想在这里区分一个概念：**加密，解密，签名，验证**。

我们可以使用非对称算法：有2个场景，加解密场景和签名场景。首先明确一个观点，从数学角度来讲，来公钥运算的结果，可以使用私钥解开，反之，亦然。简而言之，就是一个运算的，另外一个，可以反解回去。那么我们为什么还要区分呢？

主要是从场景，在加密场景，我们希望的是，某人加密后，只有我才可以解开，所以在加密场景，是公钥加密，私钥解密。在签名场景，我们希望，我签名后，任何人都可以验证（实际中，验证的是实际内容的hash），所以是私钥签名，公钥验证。

在实际中，前者的应用场景很少，主要是速度慢，不用在大量数据的加密中。

# 2. DSA 

签名s应当是秘密数字x，消息的哈希值H(m)和随机数字k的一个函数。s=f(x,H(m),k)

我们如何在不知道x和k的情况下验证该等式呢。

我们可以借助于上章学习的离散对数问题。y=g^x mod p 和r=g^k mod p发送给接受者，不用担心x和k的泄露。一般称x为私钥，y为公钥，<r,s>为数字签名。

签名关系F和签名函数f是等价的，而验签关系G是由F决定的。因此关系F是决定签名方案的关键。

我们最容易想到的一种方案是让 中各数字之间有加法运算,如：

s=x+k+H(m)mod(p-1)

所以，G应当为：g^s≡g^(x+k+H(m)) mod p=g^xg^k*g^H(m) mod p≡yr * g^H(m) mod p

所以，接收方需要验证关系：g^s≡yr * g^H(m) mod p是否成立就可以验证签名了。

但是目前仍然存在问题，即正常的签名是可以通过验证的啊，但是可能被攻击者进行攻击。攻击者很容易在不知晓x和k的情况下，伪造签名r和s。

那么如何进行伪造呢？

攻击者只要先对s任取一值s’，然后通过解方程g^s≡yr * g^H(m) mod p,得到r'≡g^s'/(y * g^H(m)) mod p。

显然满足上述公式的r'和s'也可以验证通过。



所以我们必须修改方案，可以借助上面学习的离散对数问题，可以让验签方案中的s和都出现在指数上，这样攻击者就必须解决离散对数问题，才可能实施攻击。所以我们需要调整验签方案G和签名方案F。

我们可以将签名关系F修改为：sk≡H(m)+xr (mod (p-1)),则签名函数s为s=(H(m)+xr) /k mod(p-1),即k=(H(m)+xr) /s mod(p-1),所以有：r=g^k mod p=g^(H(m)+xr)/s mod p=g^(H(m))/s * g^(r/s) mod p

在该等式的结果中，仅包含签名<r,s>，公钥y和消息m，不会泄露私钥x,k。所以可以使用该等式作为验签关系:

G:r=g^(H(m))/s * g^(r/s) mod p由于r和s都在指数上，所以攻击者无法伪造签名。

总计一下，我们的DSA的签名方案为：

r=g^k mod p;

s=(H(m)+xr) /k mod(p-1)

验签方案为：

r=g^(H(m))/s * g^(r/s) mod p

事实上，上面的方案还是存在着不足，即为了防止离散对数数学问题不被暴力破解，通常素数p的值需要很大，为了减小数字签名的规模，我们需要采取一定的措施：

选择一个相对较小的整数q，使q满足g^q mod p=1,如果 p取1024比特，那么q就取160比特。

这样，s和q修改为相同的规模，r的大小不变。所以我们需要把r缩减为同等规模。即r修改为

r= (g^(H(m)/s * y^(r/s) mod p)) mod q;

到此，我们总结下，DSA的签名方案为：

**签名过程：**

第一步，生成参数素数p，素数q，底数 g，满足g^q mod p=1；用户公钥为：随机选取x,计算公钥*y* = *g^x* mod *p*.

第二步，对每一个消息m，生成随机数 k,1<k<q；

第三步，计算r=(g^k mod p) mod p,若r=0,重复该步骤；

第四步，计算s=(H(m)+xr)/k mod q，若 s=0,重复该步骤；

第五步，令<r,s>为数字签名。



第二步和第三步是为每条消息产生一个密钥，

**验证过程：**

检查该过程是否成立：

- 0<r<q;
- 0<s<q;
- w=s^-1 mod q
- u1=H(m)*w mod q
- u2=r*w mod q 
- v = (g^u1* y^u2 mod p) mod q
- 判断v和r是否相等。

算法的正确性验证：



**总结：**

第一，为了防止泄露私钥 ，只能公开公钥 ；

第二，为了防止伪造签名，必须在验签方案中让签名出现在指数上；

第三，为了减小数字签名规模，为指数选择一个相对较小的模数。

而这一切都建立在**素数域**GF(p)中的整数加法、乘法、幂和离散对数的运算性质上。

如果将素数域更换为有限域上的椭圆曲线，运算的对象变为椭圆曲线上的点，那么仍然可以定义出具有类似性质的加法、乘法。参照我们的DSA探秘之路，你自己就可以设计出具有更高安全性的椭圆曲线数字签名方案ECDSA，而ECDSA正是比特币体系使用的数字签名方案。



# 3. ECDSA 

| Parameter |                                                              |
| --------- | ------------------------------------------------------------ |
| CURVE     | the elliptic curve field and equation used                   |
| *G*       | elliptic curve base point, such as a pt {\displaystyle (x_{0},y_{0})}![(x_{0},y_{0})](https://wikimedia.org/api/rest_v1/media/math/render/svg/29c296094af9a1c665425debeac5eaab99a37a04) on {\displaystyle y^{2}=x^{3}+7}![{\displaystyle y^{2}=x^{3}+7}](https://wikimedia.org/api/rest_v1/media/math/render/svg/2e5b7a09643d5da81c32abf12cb0a4816442299b), a generator of the elliptic curve with large prime order *n* |
| *n*       | integer order of *G*, means that {\displaystyle n\times G=O}![n\times G=O](https://wikimedia.org/api/rest_v1/media/math/render/svg/8340b0e30a45c48c84732ee61306887db59ce2b8), where {\displaystyle O}![O](https://wikimedia.org/api/rest_v1/media/math/render/svg/9d70e1d0d87e2ef1092ea1ffe2923d9933ff18fc) is the identity element. |

椭圆曲线签名算法原理，椭圆曲线签名算法，即ECDSA。
设私钥、公钥分别为k、K，即K = kG，其中G为G点。

签名过程如下：

1. 选择一条椭圆曲线Ep(a,b)，和基点G；

2、选择私有密钥k（k<n，n为G的阶），利用基点G计算公开密钥K=kG；

3、产生一个随机整数r（r<n），计算点R=rG；

4、将原数据和点R的坐标值x,y作为参数，计算SHA1做为hash，即Hash=SHA1(原数据,x,y)；

5、计算s≡r - Hash * k (mod n)

6、r和s做为签名值，如果r和s其中一个为0，重新从第3步开始执行

验证过程如下：

1、接受方在收到消息(m)和签名值(r,s)后，进行以下运算

2、计算：sG+H(m)P=(x1,y1), r1≡ x1 mod p。

3、验证等式：r1 ≡ r mod p。

4、如果等式成立，接受签名，否则签名无效。

**原理如下**：
hG/s + xK/s = hG/s + x(kG)/s = (h+xk)G/s = r(h+xk)G / (h+kx) = rG

```java
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

/**
 * 椭圆曲线签名算法
 * 
 * 速度快 强度高 签名短
 * 
 * 实现方 JDK1.7/BC
 */


public class ECDSAUtil {

   private static String str = "hello";

   public static void main(String[] args) {
      jdkECDSA();
   }

   public static void jdkECDSA() {

      try {
         //第一步：初始化化秘钥组，生成ECDSA算法的公钥和私钥
         KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("EC");
         keyPairGenerator.initialize(256);

         KeyPair keyPair = keyPairGenerator.generateKeyPair();
         ECPublicKey ecPublicKey = (ECPublicKey) keyPair.getPublic();
         ECPrivateKey ecPrivateKey = (ECPrivateKey) keyPair.getPrivate();
         System.out.println("PublicKey:"+ecPublicKey.toString());
         // 2.执行签名
         PKCS8EncodedKeySpec pkcs8EncodedKeySpec = new PKCS8EncodedKeySpec(ecPrivateKey.getEncoded());
         KeyFactory keyFactory = KeyFactory.getInstance("EC");

         PrivateKey privateKey = keyFactory.generatePrivate(pkcs8EncodedKeySpec);
         Signature signature = Signature.getInstance("SHA1withECDSA");
         signature.initSign(privateKey);

         signature.update(str.getBytes());
         byte[] sign = signature.sign();
         System.out.println("signResult:"+sign.toString());


         //3.验证签名
         X509EncodedKeySpec x509EncodedKeySpec = new X509EncodedKeySpec(ecPublicKey.getEncoded());
         keyFactory = KeyFactory.getInstance("EC");
         PublicKey publicKey = keyFactory.generatePublic(x509EncodedKeySpec);
         signature = Signature.getInstance("SHA1withECDSA");
         signature.initVerify(publicKey);
         signature.update(str.getBytes());

         boolean bool = signature.verify(sign);
         System.out.println(bool);

      } catch (Exception e) {
         e.printStackTrace();
      }
   }
}
```

# 4. HMAC

全称是 Hash-based Message Authentication Code，即“基于 Hash 的消息认证码”。基本过程为对某个消息，利用提前共享的对称密钥和 Hash 算法进行加密处理，得到 HMAC 值。该HMAC 值提供方可以证明自己拥有共享的对称密钥，并且消息自身可以利用 HMAC 确保未经篡改。
HMAC(K, H, Message)
其中，K 为提前共享的对称密钥，H 为提前商定的 Hash 算法（ 一般为公认的经典算法） ，Message 为要处理的消息内容。如果不知道 K 和 H，则无法根据 Message 得到准确的HMAC 值。

HMAC 一般用于证明身份的场景，如 A、B 提前共享密钥，A 发送随机串给 B，B 对称加密处
理后把 HMAC 值发给 A，A 收到了自己再重新算一遍，只要相同说明对方确实是 B。

HMAC 主要问题是需要共享密钥。当密钥可能被多方拥有的场景下，无法证明消息确实来自某人（ Non-repudiation） 。反之，如果采用非对称加密方式，则可以证明。

# 5. 盲签名

1983 年由 David Chaum 提出。签名者在无法看到原始内容的前提下对信息进行签名。《Blind Signatures for Untraceable Payment》

盲签名主要是为了实现防止追踪（ unlinkability） ，签名者无法将签名内容和结果进行对应。典型的实现包括 RSA 盲签名)。

# 6. 多重签名

n 个持有人中，收集到至少 m 个 的签名，即认为合法，这种签名被称为多重签名。其中，n 是提供的公钥个数，m 是需要匹配公钥的最少的签名个数。



# 7. 群签名

1991 年由 Chaum 和 van Heyst 提出。群签名属于群体密码学的一个课题。

群签名有如下几个特点：只有群中成员能够代表群体签名（ 群特性） ；接收者可以用公钥验证群签名（ 验证简单性） ；接收者不能知道由群体中哪个成员所签（ 无条件匿名保护） ；发生争议时，群体中的成员或可信赖机构可以识别签名者（ 可追查性） 。

Desmedt 和 Frankel 在 1991 年提出了基于门限的群签名实现方案。在签名时，一个具有 n个成员的群体共用同一个公钥，签名时必须有 t 个成员参与才能产生一个合法的签名，t 称为门限或阈值。这样一个签名称为(n, t)不可抵赖群签名。



# 8. 环签名

环签名由 Rivest,shamir 和 Tauman 三位密码学家在 2001 年首次提出。环签名属于一种简化的群签名。

签名者首先选定一个临时的签名者集合,集合中包括签名者自身。然后签名者利用自己的私钥和签名集合中其他人的公钥就可以独立的产生签名,而无需他人的帮助。签名者集合中的其他成员可能并不知道自己被包含在其中。

