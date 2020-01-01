---
layout: post
title: "一文吃透程序间的通信"
date: 2019-12-30
description: "2019-12-30-一文吃透程序间的通信"
categories: 计算机网络
tag: 计算机网络

---

<!--ts-->
   * [前言](#前言)
   * [1. 系统级别的I/O](#1-系统级别的io)
      * [1.1 Unix I/O](#11-unix-io)
      * [1.2 打开和关闭文件](#12-打开和关闭文件)
      * [1.3 读和写文件](#13-读和写文件)
      * [1.4 用RIO包健壮读写](#14-用rio包健壮读写)
         * [1.4.1 RIO无缓冲的输入输出函数](#141-rio无缓冲的输入输出函数)
         * [1.4.2 RIO带缓冲的输入输出函数](#142-rio带缓冲的输入输出函数)
      * [1.5 读取文件元数据](#15-读取文件元数据)
      * [1.6 共享文件](#16-共享文件)
      * [1.7 I/O重定向](#17-io重定向)
      * [1.8 标准I/O](#18-标准io)
      * [1.9 综合](#19-综合)
      * [1.10 小结](#110-小结)
   * [2 网络编程](#2-网络编程)
      * [2.1 客户端-服务器编程模型](#21-客户端-服务器编程模型)
      * [2.2 网络](#22-网络)
      * [2.3 全球IP因特网](#23-全球ip因特网)

<!-- Added by: anapodoton, at: Tue Dec 31 14:49:08 CST 2019 -->

<!--te-->

# 前言

我们在这篇文章研究进程间通信。因为我们的代码肯定需要和其他的程序进行交换数据。如果只是在一台电脑上，我们可以使用系统级别的I/O,如果不在一台电脑上呢，我们可以使用socket网络编程。更为特殊的是，我们还会面临高并发编程这个很困难的问题。

# 1. 系统级别的I/O

输入/输出 是在主存和外部存储设备之间复制数据的过程，输入操作是从I/O设备复制到主存，输出操作是从主存到I/O设备。

## 1.1 Unix I/O

一个linux文件是m个字节的序列，所有的I/O设备都被模型化为文件，所有的输入输出都被当做对相应文件的读和写来执行。这种方式允许Unix内核引出一个低级别的应用接口，称做Unix I/O,输入和输出的方式是一致的。

- 打开文件：应用程序通过内核访问一个文件，内核返回一个非常小的非负整数，叫做**描述符**，程序的所有操作都依赖这个描述符标识。内核负责记录文件的信息，程序只需要这个描述符。
  - Unix shell为每个进程创建了三个打开的文件，标准输入（描述符0）标准输出（描述符1）标准错误（描述符2）头文件定义了常量STDIN_FILENO STDOUT_FILENO STIERR_FILENO 来代替描述符值
- 改变当前的文件位置：通过seek操作文件的位置为k（k是相对于当前文件的偏移量），初始为0，记录偏移量
- 读写文件：读就是复制n>0个字节到内存中，从当前文件位置k开始，复制k~k+n。文件大小为m，k>=m时，会触发end-of-file(EOF)，应用程序可以检测到，文件的结尾没有EOF符号。写操作类似。
- 关闭文件：内核释放文件打开时创建的数据结构，并恢复描述符到可用的描述符池中，无论何种原因终止，内核都会关闭所打开的文件并释放存储器。

## 1.2 打开和关闭文件

通过open来打开,成功的话是文件描述符，失败的话是-1。

```
int open(char *filename, int flags, mode_t mode)
```

flag是进程如何去访文件，只读，只写，可读可写。

mod是新文件的访问权限位，如下所示：

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191230222716.png" style="zoom:50%;" />

通过close来关闭一个已打开的文件。需要注意的是关闭一个已关闭的文件描述符会报错。

int close(int fd)

## 1.3 读和写文件

```c
# 成功的话是字节数，EOF的话是0，出错是-1.
# 从描述符为fd的当前文件位置拷贝至多n个字节到缓存器buf
ssize_t read(int fd, void *buf, size_t n);
# 成功是字节数，失败是-1
# 从buf拷贝至多n个字节到fd的当前位置
ssize_t write(int fd, const void *buf, size_t n);
```

注意，在下面的这些情况下，我们可能会遇到read和write传送的字节少于要求的：

- 读时遇到EOF

- 如果从终端读输入, 一次性读入的是一个文本行, 返回的不足值等于文本行的大小. 
- 如果读取网络套接字socket, 很有可能因为网络分包和延迟到达, 返回不足值。

这个时候要反复读取直到读取到尾部才可以.

## 1.4 用RIO包健壮读写

为了解决不足值的问题，我们引入了RIO（Robust I/O）。

- 无缓冲的输入输出函数
- 带缓冲的输入输出函数

### 1.4.1 RIO无缓冲的输入输出函数

同read和write一样，不同的是可以直接在存储器和文件之间传输数据。

```
ssize_t rio_readn(int fd, void *usrbuf, size_t n)
ssize_t rio_writen(int fd, void *usrbuf, size_t n)
```



```c
ssize_t rio_readn(int fd, void *usrbuf, size_t n)
{
    //要读取的总数, 为了后边计算剩余未读取的字节之用
    size_t nleft = n;
    //已经读取的数量
    ssize_t nread;
    //内存位置
    char *bufp = usrbuf;

    //在剩余还需要读取的字节大于0的时候, 不断循环
    while (nleft > 0) {
        //调用read函数, 失败的情况下进行判断
        if ((nread = read(fd, bufp, nleft)) < 0) {
            //检测errno判断是否被中断, 如果中断就设置nread = 0, 然后从头读取
            if (errno == EINTR)
                nread = 0;      /* and call read() again */
            //出错退出
            else
                return -1;
        }
        //调用read 函数,读到末尾的情况下说明已经读取完毕, 跳出循环
        else if (nread == 0)
            break;
        //正常读取, 原来剩余的值减去已经读取的值, 得到新的剩余的值, 参与下一次循环, 同时移动指针读下一段内存区域.
        nleft -= nread;
        bufp += nread;
    }
    //返回已经读取的总字节数, 用 n 减去 剩余未读取的字节, 就是0.
    return (n - nleft);
}
```

通过分析这个函数, 可以发现其工作原理, 就是反复的调用系统函数读取, 每一次尝试读取上一次剩余的数量. 这个对于网络设备比较通用. 注意这个程序没有使用缓冲区作为中转, 而是直接将内容不断的写入*bufp开始的区域, 也不会去判断*bufp区域是否存在缓冲区溢出的问题.

```c
ssize_t rio_writen(int fd, void *usrbuf, size_t n)
{
    //剩余要写入的字节
    size_t nleft = n;
    //已经写入的字节
    ssize_t nwritten;
    //目标内存区域
    char *bufp = usrbuf;

    //与读入函数一样的循环
    while (nleft > 0) {
        //调用write函数, 尝试写入
        //写完了或者写入错误的情况下
        if ((nwritten = write(fd, bufp, nleft)) <= 0) {
            //一样的检测中断机制, 如果被中断, 设置已经写入是0, 重新再写
            if (errno == EINTR)
                nwritten = 0;
            //errno是其他表示真的出错了, 返回-1结束程序
            else
                return -1;
        }
        //计算剩余的要写入的数量
        nleft -= nwritten;
        //移动指针
        bufp += nwritten;
    }
    return n;
}
```

写函数不会判断*bufp会不会有缓冲区错误, 就一直写. 综合两个函数来看, 这个信号打断后重新处理的机制比较巧妙, 利用了被中断之后read和write会返回错误的特点, 去检测错误码, 然后设置字节数量. 这样在下一个循环里又可以从当前位置再来继续读取.

### 1.4.2 RIO带缓冲的输入输出函数 

带缓冲的输入输出函数主要用于处理本地文件. 由于每次读写文件, 都是系统调用, 需要陷入内核态, 如果一个一个字节读取显然效率很低. 一般是使用应用程序级别的缓冲区, 一次性读入一些内容, 处理完, 再读入.

由于有了缓冲区, 除了底层要继续调用 read 和write 来不断读取之外, 还必须维护缓冲区. 为此设置三个函数:

```
//初始化读取的函数, 将描述符与一个rp指向的缓冲区联系起来
void rio_readinitb(rio_t *rp, int fd);

//带缓冲区的read()函数, 是这部分函数的核心, 以下两个函数都调用这个函数
static ssize_t rio_read(rio_t *rp, char *usrbuf, size_t n)

//从*rp读入下一个文本行, 将其复制到内存位置 usrbuf
ssize_t rio_readnb(rio_t *rp, void *usrbuf, size_t n)

//上一个函数的读字节的版本. 从rp最多读取n个字节到内存位置, 然后在末尾添一个\0.对同一个描述符, rio_readnb 和 rio_readlineb可以任意交叉反复调用
ssize_t rio_readlineb(rio_t *rp, void *usrbuf, size_t maxlen)
```

所以可以发现, 实际上需要先创建一个结构, 指定好缓冲区, 在读取的时候, 就利用这个结构来操作缓冲区.

按一个将一个文本文件一行一行的从标准输入复制到标准输出的主程序来分析代码:

```
int main(int argc, char **argv){
    int n;
    //初始化结构
    rio_t rio;
    //这个是目标内存区域, MAXLINE在csapp.h里定义的是8192, 即一行最多是8192个字符
    char buf[MAXLINE]

    //初始化, 即将标准输入与rio结构联系起来
    Rio_readinitb(&rio, STDIN_FILENO);
    //反复调用, 只要调用的读取行的函数不为0, 就将读取的行写入标准输出
    while((n = Rio_readlineb(&rio, buf, MAXLINE))!=0){
        Rio_writen(STDOUT_FILENO, buf, n);
    }
}
```

首先程序中声明了 n 用于判断读取是否结束. 然后声明了 rio_t 结构 和 buf 数组作为缓冲区.

初始化的函数很重要, 是如何将缓冲区和文件描述符联系起来的呢, 核心就是 rio_t 结构:

```
#define RIO_BUFSIZE 8192
typedef struct {
    //文件描述符
    int rio_fd;
    //尚未读取的字节
    int rio_cnt;
    //指向缓冲区内下一个空白处的指针
    char *rio_bufptr;
    //这里设置了一个内部缓冲区
    char rio_buf[RIO_BUFSIZE];
} rio_t;
```

有了这样一个结构之后, 通过rio_readinitb设置一下这个结构的内容, 在不同的函数之间传递这个结构, 就可以把缓冲区和文件描述符联系起来.

```
void rio_readinitb(rio_t *rp, int fd)
{
    // 设置rio_t结构的文件描述符
    rp->rio_fd = fd;
    // 内部缓冲区中尚未读取的字节
    rp->rio_cnt = 0;
    // 指针指向内部缓冲区的开始
    rp->rio_bufptr = rp->rio_buf;
}
```

然后来看看核心的rio_read函数:

```
static ssize_t rio_read(rio_t *rp, char *usrbuf, size_t n)
{
    int cnt;

    //先判于断rio_t结构中的尚未读取的字节是不是小于等0. 如果是的话说明内部缓冲区没有东西, 可以调用read来读入一些内容
    while (rp->rio_cnt <= 0) {
        //调用read, 传入的长度是内部缓冲区的总长度, 从rio_t 结构中的fd 读取到内部缓冲区中, 并且返回读取的结果, 设置到 rio_t 结构的rio_cnt上
        rp->rio_cnt = read(rp->rio_fd, rp->rio_buf,
                           sizeof(rp->rio_buf));
        //如果读了一次, 小于0, 说明出错, 检测中断
        if (rp->rio_cnt < 0) {
            //如果不是中断导致的, 就出错退出
            if (errno != EINTR) /* Interrupted by sig handler return */
                return -1;
            //如果是中断, 继续向下执行, 也就到了循环末尾, 再读一次
        }
        //如果等于0, 说明到了尾部, 返回0
        else if (rp->rio_cnt == 0)
            return 0;
        //如果大于0, 说明成功读取, 此时要将指针重新指向开头.
        else
            rp->rio_bufptr = rp->rio_buf;
    }

    //如果一进函数发现本来rio_t 中的 cnt 大于0, 说明还有内部缓冲区的内容没有被复制到目标内存区域中去
    //此时要挑cnt 和 n 两个里边的较小值进行复制, 否则就越界了
    cnt = n;
    //让cnt变量等于 n 和rio_t中的cnt的较小值
    if (rp->rio_cnt < n)
        cnt = rp->rio_cnt;
    //复制内部缓冲区的内容到目标内存区域, 注意, 每一次复制都是复制到目标区域的开始
    memcpy(usrbuf, rp->rio_bufptr, cnt);
    //移动内部缓冲区指针到剩余未读取区域. 即使读光了也没有关系, 下一次再执行读取的时候, 这个指针会根据cnt的值重新设置.如果cnt<=0且成功读取,就会复位到内部缓冲区的开头
    rp->rio_bufptr += cnt;
    //rio_cnt的数值减去已经读取的数值
    rp->rio_cnt -= cnt;
    return cnt;
}
```

这个函数的本质就是每次进函数, 先把内部缓冲区的东西都发送干净, 再读取新内容到内部缓冲区来. 直到读完为止返回0.

rio_readnb 和 rio_readlineb 内部都使用了 rio_read 函数. 来看看这两个函数:

```
ssize_t rio_readnb(rio_t *rp, void *usrbuf, size_t n)
{
    //尚未读取的数量
    size_t nleft = n;
    //已经读取的数量
    ssize_t nread;
    //内存区域
    char *bufp = usrbuf;

    //调用rio_read
    while (nleft > 0) {
        //失败返回-1
        if ((nread = rio_read(rp, bufp, nleft)) < 0)
            return -1;
        //到末尾返回0
        else if (nread == 0)
            break;
        //和之前一样的套路, 减去已经读取的, 剩下未读取的,再循环
        nleft -= nread;
        //移动目标内存的指针, 继续写入未读取完的部分
        bufp += nread;
    }
    return (n - nleft);
}
```

这个函数内部依靠rio_read函数, 反复读取, 直到把所有的标准输入的内容都读取到内存中. rio_read内部的缓冲区对于这个函数是不可见的, 其行为就和调用 read 函数一样.

```
ssize_t rio_readlineb(rio_t *rp, void *usrbuf, size_t maxlen)
{
    int n, rc;
    char c, *bufp = usrbuf;

    //这里是读取指定长度的字节, 用的是逐个读取. 读到\n就会跳出循环.
    for (n = 1; n < maxlen; n++) {
        if ((rc = rio_read(rp, &c, 1)) == 1) {
            *bufp++ = c;
            if (c == '\n') {
                n++;
                break;
            }
        //如果读不到了, 但是长度是1, 表示只读取了一个换行符, 因此返回0
        } else if (rc == 0) {
            if (n == 1)
                return 0;
            //如果读的长度不是0, 就说明读完了, 跳出循环
            else
                break;
        } else
            return -1;
    }
    //给末尾写入0, 也就是ASCII码的\0
    *bufp = 0;
    //返回读入的字符数量, 不包括换行符.
    return n-1;
}
```

rio_readlineb 是读取字节的版本, 这里因为读取输入的时候不是按行读取, 而是一个一个字节的读取, 直到读到换行符为止, 然后放入一个0.

在上边的主程序中使用的首字母大写的函数Rio_readlineb 和 Rio_writen 其实是对应函数的包装. 由于写函数是不需要内部缓冲区的, 所以依然使用同一个写函数.

这样就分析完了线程安全的一个Rio包, 以后在自己的程序中也可以使用.

## 1.5 读取文件元数据

可以使用stat和fstat函数来检索关于文件的信息（metadata）。

```c
# 成功返回0，出错是-1
int stat(const char *filename, struct stat *buf)
int fstat(int fd, struct stat *buf)
```

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191230232700.png" style="zoom:50%;" />

st_size是文件的字节数大小，st_mode是文件类型。

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191230232823.png)

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191230232932.png" style="zoom:25%;" />

## 1.6 共享文件

**需要找更加详细的资料来看。**

内核用三种数据结构来表示打开的文件：

1. 描述符表(descriptor table)： 每个进程都有独立的描述符表，表项是由进程打开的文件描述符来索引的，每个打开的描述符表项指向文件表中的一个表项。
2. 文件表（file table）:打开的文件集合是由一张文件表来表示的，所有进程共享这张表.，每个文件表的表项组成包括有当前的文件位置，引用计数（reference count）即当前指向该表项的描述符表项数，以及一个指向v-node表对应的表针，关闭一个描述符会减少相应的文件表表项的引用计数，内核不会删除文件表表项，直到他的引用计数为0。
3. v-node表. 所有进程也共享这个表, 每个表项包含stat结构中的大部分成员内容。

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231110930.png" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231111047.png" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231111157.png" style="zoom:50%;" />

练习 10.2 下列程序的输出是什么

```c
int main(){
    int fd1, fd2;
    char c;

    fd1 = open("foo.txt", O_RDONLY, 0);
    fd2 = open("foo.txt", O_RDONLY, 0);
    Read(fd1, &c, 1);
    Read(fd2, &c, 1);

    printf("c = %c\n", c);
    exit(0);
}
```

foo.txt的内容是 foobar . 这个程序使用了两次调用, 对同一个文件获取了不同的描述符, 两个描述符在新建的时候, 指向不同的文件表的位置, 所以第一次读是f, 第二次读还是f. 所以打印出的是f

练习 10.3 下列程序的输出是什么 foo.txt的内容是字符 foobar

```c
int main(){
    int fd1;
    char c;

    fd = open("foo.txt", O_RDONLY, 0);

    if (fork() == 0) {
        Read(fd, &c, 1);
        exit(0);
    }
    Wait(NULL);
    Read(fd, &c, 1);
    printf("c = %c\n", c);
    exit(0);
}
```

可以看到, 父进程等待子进程完成全部工作之后, 再去读取&c的一个位置. 由于read函数会移动文件指针, 而父子进程的fd描述符指向同一个文件表项, 因此共享文件位置.

父进程在读1个字符的时候, 子进程已经读取过一个字符并且将文件位置移到了第二个字符, 所以父进程会读取并打印o

## 1.7 I/O重定向

I/O重定向用到了dup2函数：

```c
#include <unistd.h>
int dup2(int oldfd, int newfd);
```

dup2拷贝oldfd到newfd, 覆盖newfd之前的内容，如果newfd已经被打开, 在重定向之前, dup2 会先关闭 newfd。

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231113431.png" style="zoom:50%;" />

## 1.8 标准I/O

提供了打开和关闭的函数：fopen和fclose；

读和写字节的函数：fread和fwrite;

读和写字符串的函数：fgets和fputs；

格式化I/O函数：scanf和printf；

## 1.9 综合

在程序中应该使用哪一个I/O函数？

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231113812.png" style="zoom:50%;" />

- 优先使用标准I/O函数（用于磁盘和终端设备）
- scanf 和rio_readlineb是专门设计用来读文本的，不要读二进制
- 网络套接字应使用RIO

**限制：** 

- 输入函数不能跟在输出函数之后，除非有fflush（清空与流相关的缓存区）[ fseek fsetpos rewind（使用lseek函数重置当前文件位置）] 调用
- 输出函数不能再输入函数之后，除非有fseek fsetpos rewind的调用

## 1.10 小结

Unix I/O提供了少量的系统级函数，允许应用程序打开，关闭，读写文件，提取文件的元数据和I/O重定向。但是Unix I/O会出现不足值的问题，所以我们一般不要直接调用Unix I/O，尽量使用RIO，RIO通过反复执行读写操作，直到传送完所有的请求数据，自动处理不足值。

Unix内核使用三种数据结构来表示打开的文件，描述符表指向打开文件表中的表项，打开文件表的表项指向v-node表中的表项，每个进程有自己的描述符表，所有的进程共享文件表和v-node表，只有理解了这个，才可以理解文件共享和I/O重定向。

# 2 网络编程

## 2.1 客户端-服务器编程模型

**客户端-服务器模型**: 一个应用由一个服务器进程和一个或多个客户端进程组成.

客户端-服务器模型中的基本操作是事务, 一个事务由如下四个步骤组成:

1. 客户端向服务器发起请求
2. 服务器收到请求后解释, 然后进行操作
3. 操作完成后发送一个响应, 并等待下一个请求
4. 客户端收到响应并处理

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231121130.png" style="zoom:50%;" />

 要认识到客户端和服务器并不是主机, 而是一个一个进程. 因此一台机器上可以有很多服务器和客户端.

## 2.2 网络

1. 对主机而言, 网络也只是一种I/O设备, 是数据源和数据接收方. 数据可以从网络适配器复制到内存, 也可以从内存复制到网络适配器.
2. 物理上, 网络是一个按照地理远近组织的层次系统, 最低层是LAN即局域网, 局域网所使用的技术叫做以太网. 以太网段内的电缆具有相同的带宽
3. 一个以太网段包括用电缆和集线器互相连接的计算机, 以太网通常跨越一些小的区域, 比如一栋楼. 每一个电缆从主机连接到集线器, 集线器将每个收到的信号不加区别的复制到所有的端口上, 所有的主机都可以看到所有的数据.
4. 每一个以太网适配器上边有一个全球唯一的48位地址, 即MAC地址. 主机可以发送一段二进制位(被称为一个帧 frame)到当前网段的任何主机, 每个帧包括一定的头部信息用来标识帧的源头和目的地以及此帧的长度, 之后是有效载荷. 由于集线器将数据复制到所有接口, 所以所有同网段的主机都能看到, 但只有目的主机接收它.
5. 使用一种网桥设备, 可以将多个以太网段连接成较大的局域网, 称为桥接以太网. 连接桥与桥的电缆的速度一般比局域网内的速度要快. 网桥与集线器不同, 会有选择的转发信息.
6. 多个局域网使用路由器的特殊计算机来连接, 组成一个互联网. 每台路由器对于它连接到的每个网络都有一个适配器(端口),

由此可见, 其实全世界互联网上的电脑, 都是通过多层的设备物理连接在一起的, 由不同技术的局域网和广域网组成, 如何能让一台计算机的信息可以达到任何一台计算机呢?

答案是每台路由器和主机上, 都有相关的协议软件, 控制所有的设备协同发送和处理数据. 协议软件提供两种基本机制:

1. 命名机制, 每台主机会被分配一个互联网络地址.
2. 传送机制, 将数据统一包装成不连续的片(称为包)来消除了差异. 每个包都由包头和有效载荷组成.



<img src="https://tva1.sinaimg.cn/large/006tNbRwly1gafvq6szd0j30ps0m6jwd.jpg" alt="image-20191231122201541" style="zoom:50%;" />

<img src="https://tva1.sinaimg.cn/large/006tNbRwly1gafvq7xczgj30w60jwq5r.jpg" alt="image-20191231122511074" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231144215.png" style="zoom:50%;" />

## 2.3 全球IP因特网

1. 主机集合是32位的IP地址的集合
2. IP地址被映射成域名
3. 机器之间可以通过connection 连接 来进行通信

### 2.3.1 IP地址

**IP地址**是一个32位无符号整数, 表示的时候用 x.x.x.x 来表示, 每个x都是一个8位二进制数的无符号十进制表示, 也就是从0-255.

IP地址在系统里是一个结构:

```
struct in_addr {
    uint32_t s_addr;
}
```

由于主机可能有大端法或者小端法, TCP/IP规定了网络字节顺序按照大端字节顺序进行存放. 比如IP地址, 在网络传输的时候按照大端法排列. Unix有如下函数用于转换网络字节顺序和主机字节顺序:

```c
#include <netinet/inet.h>

//主机转网络
uint32_t htonl(uint32_t hostlong);
uint16_t htonl(uint16_t hostlong);

//网络转主机
uint32_t ntohl(uint32_t netlong);
uint16_t ntohs(uint16_t netshort);
```

这些函数没有处理64位的函数, 看来处理64位需要自己排布.

还有两个函数可以用来转换IP地址和十进制表示的IP地址:

```c
#include <arpa/inet.h>

//将src转换成IP地址放入dst指针指向的对象内. 如果成功返回1, 如果src非法返回0, 如果出错返回-1
int inet_pton(AF_INET, const char *src, void *dst);

//将IP地址转换成字符串, 返回指向字符串的指针, 出错就返回NULL
const char *inet_ntop(AF_INET, const void *src, char *dst, socklen_t size);
```

这些函数一般用n表示网络, p表示字符串表示. AF_INET 表示32位 IPV4 地址, 其实还可以处理 128位的IPV6地址.

### 2.3.2 域名

### 2.3.3 因特网连接

对于程序员来说, 关键就是要搞清楚连接的端点及套接字。（cliaddr:clipart, servaddr:servport）

## 2.4 套接字接口

套接字接口(socket interface)结合Unix I/O来创建网络应用的函数。

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231222603.png" style="zoom:50%;" />

### 2.4.1 套接字地址结构

