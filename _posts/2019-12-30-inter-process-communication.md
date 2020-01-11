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
         * [2.3.1 IP地址](#231-ip地址)
         * [2.3.2 域名](#232-域名)
         * [2.3.3 因特网连接](#233-因特网连接)
      * [2.4 套接字接口](#24-套接字接口)
         * [2.4.1 套接字地址结构](#241-套接字地址结构)
         * [2.4.2 socket函数，取得文件描述符](#242-socket函数取得文件描述符)
         * [2.4.3 connect函数](#243-connect函数)
         * [2.4.4 open_clientfd函数](#244-open_clientfd函数)
         * [2.4.5 bind函数：What port am I on？](#245-bind函数what-port-am-i-on)
         * [2.4.6 listen函数，有人会调用我吗？](#246-listen函数有人会调用我吗)
         * [2.4.7 open_listenfd函数](#247-open_listenfd函数)
         * [2.4.8 accept函数](#248-accept函数)
         * [2.4.9 echo客户端和服务端](#249-echo客户端和服务端)
      * [2.5 web服务器](#25-web服务器)

<!-- Added by: anapodoton, at: Thu Jan  2 23:40:01 CST 2020 -->

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

```cpp
// include/linux/fdtable.h of linux-2.6.37

struct fdtable {
        unsigned int max_fds;
        struct file __rcu **fd;      /* current fd array */
        fd_set *close_on_exec;
        fd_set *open_fds;
        struct rcu_head rcu;
        struct fdtable *next;
};

/*
 * Open file table structure
 */
struct files_struct {
  /*
   * read mostly part
   */
        atomic_t count;
        struct fdtable __rcu *fdt;
        struct fdtable fdtab;
  /*
   * written part on a separate cache line in SMP
   */
        spinlock_t file_lock ____cacheline_aligned_in_smp;
        int next_fd;
        struct embedded_fd_set close_on_exec_init;
        struct embedded_fd_set open_fds_init;
        struct file __rcu * fd_array[NR_OPEN_DEFAULT];
};
```

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20200102195821.png" style="zoom: 33%;" />

内核用三种数据结构来表示打开的文件：

1. 描述符表(descriptor table)： 每个进程都有独立的描述符表，表项是由进程打开的文件描述符来索引的，每个打开的描述符表项指向文件表中的一个表项。
2. 文件表（file table）:打开的文件集合是由一张文件表来表示的，所有进程共享这张表.，每个文件表的表项组成包括有当前的文件位置，引用计数（reference count）即当前指向该表项的描述符表项数，以及一个指向v-node表对应的表针，关闭一个描述符会减少相应的文件表表项的引用计数，内核不会删除文件表表项，直到他的引用计数为0。
3. v-node表. v节点包含了文件类型和对此文件进行各种操作的函数的指针信息。所有进程也共享这个表, 每个表项包含stat结构中的大部分成员内容。

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

//主机序转网络序
uint32_t htonl(uint32_t hostlong);
uint16_t htonl(uint16_t hostlong);

//网络序转主机序
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

IP地址和域名之间的关系是多对多。

### 2.3.3 因特网连接

对于程序员来说, 关键就是要搞清楚连接的端点及套接字。（cliaddr:clipart, servaddr:servport）

## 2.4 套接字接口

套接字接口(socket interface)结合Unix I/O来创建网络应用的函数。

<img src="https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20191231222603.png" style="zoom:50%;" />

我们先来看下addrinfo，用来准备之後要用的 socket 地址数据结构，也用在主机名（host name）及服务名（service name）的查询。

```cpp
struct addrinfo {
    int ai_flags; // AI_PASSIVE, AI_CANONNAME 等。
    int ai_family; // AF_INET, AF_INET6, AF_UNSPEC
    int ai_socktype; // SOCK_STREAM, SOCK_DGRAM
    int ai_protocol; // 用 0 当作 "any"
    size_t ai_addrlen; // ai_addr 的大小，单位是 byte
    struct sockaddr *ai_addr; // struct sockaddr_in 或 _in6
    char *ai_canonname; // 典型的 hostname
    struct addrinfo *ai_next; // 链表丶下个节点
};
```

### 2.4.1 套接字地址结构

套接字就是一个有相应描述符的文件,系统里的套接字地址数据类型是 sockaddr_in 的16字节长度的结构中。

```c
// Generic socket address structure （for connect，bind，and accept）
struct sockaddr {
    uint16_t sa_family;        // address family, AF_xxx
    char sa_data[14];           // 14 bytes of protocol address,
    														//包含一个 socket 的目地地址与port number
}
// Internet-style socket address strcture
struct sockaddr_in {
    uint16_t sin_family;        //Address family, AF_INET
    uint16_t sin_port;          //Port number
    struct in_addr sin_addr;    //Internet address
    unsigned char sin_zero[8]   //与struct sockaddr相同的大小
}
```

然后我们来看点所需的基础知识，先来看getaddrinfo：

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

int getaddrinfo(const char *node, // 例如： "www.example.com" 或 IP
const char *service, // 例如： "http" 或 port number
const struct addrinfo *hints,//指向一个你已经填好相关资料的 struct addrinfo
struct addrinfo **res);// 返回结果
```

下面来看个demo：

```c
/*
** showip.c -- 显示命令行中所给的主机 IP address
*/
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>

int main(int argc, char *argv[])
{
　　struct addrinfo hints, *res, *p;
　　int status;
　　char ipstr[INET6_ADDRSTRLEN];
　　
　　if (argc != 2) {
　　　　fprintf(stderr,"usage: showip hostname\n");
　　　　return 1;
　　}

　　memset(&hints, 0, sizeof hints);
　　hints.ai_family = AF_UNSPEC; // AF_INET 或 AF_INET6 可以指定版本
　　hints.ai_socktype = SOCK_STREAM;

　　if ((status = getaddrinfo(argv[1], NULL, &hints, &res)) != 0) {
　　　　fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
　　　　return 2;
　　}

　　printf("IP addresses for %s:\n\n", argv[1]);

　　for(p = res;p != NULL; p = p->ai_next) {
　　　　void *addr;
　　　　char *ipver;

　　　　// 取得本身地址的指针，
　　　　// 在 IPv4 与 IPv6 中的栏位不同：
　　　　if (p->ai_family == AF_INET) { // IPv4
　　　　　　struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
　　　　　　addr = &(ipv4->sin_addr);
　　　　　　ipver = "IPv4";
　　　　} else { // IPv6
　　　　　　struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
　　　　　　addr = &(ipv6->sin6_addr);
　　　　　　ipver = "IPv6";
　　　　}

　　　　// convert the IP to a string and print it:
　　　　inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
　　　　printf(" %s: %s\n", ipver, ipstr);
　　}

　　freeaddrinfo(res); // 释放链表

　　return 0;
}
```

运行结果如下：

![](https://raw.githubusercontent.com/haojunsheng/ImageHost/master/20200102222007.png)

### 2.4.2 socket函数，取得文件描述符

客户端和服务端都需要调用。

`socket`函数用来创建套接字描述符, 无论服务器还是客户端都需要先创建套接字才行.

```
#include <sys/types.h>
#include <sys/socket.h>

int socket(int domain, int type, int protocol);
```

其中的三个参数如下:

1. `domain` 表示主机名称, AF_INET表示使用32位IP地址. 之前的Head First C 中使用了PF_INET. 这个见下边详述.
2. `type` 表示套接字类型, 每个协议支持的套接字类型不同, 对于TCP/IP的连接固定使用 SOCK_STREAM 这个宏定义.
3. `protocol` 是协议编号.

关于socket函数的详情可以看[这里](https://blog.csdn.net/xc_tsao/article/details/44123331). AF指的是地址簇, 而PF指的是协议簇. TCP/IP的设计者原想是一个地址簇对应多个协议簇, 但是目前一个地址簇只有一个协议簇, 一个协议簇也只有一个协议, 因此第一个参数用AF_INET和PF_INET没什么区别, 而最后一个参数也总是0.

第二个参数会根据类型有所变动, 比如UDP协议就需要写成SOCK_DGRAM.

这个函数返回一个非负的套接字描述符, 如果出错为-1.

这个函数返回的socket描述符, 并没有分配一个地址+端口的套接字地址, 所以无法读写. 无论是服务器还是客户端都需要进一步工作.

我们可以使用getaddrinfo来填充socket函数，

```c
int s;
struct addrinfo hints, *res;

// 运行查询
// [假装我们已经填好 "hints" struct]
getaddrinfo("www.example.com", "http", &hints, &res);

// [再来，你应该要对 getaddrinfo() 进行错误检查, 并走到 "res" 链表查询能用的资料，
// 而不是假设第一笔资料就是好的［像这些示例一样］
// 实际的示例请参考 client/server 章节。
s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
```

### 2.4.3 connect函数

客户端调用。

客户端在执行完socket函数之后要做的工作是执行connect函数，来和服务端建立连接。

```cpp
#include <sys/types.h>
#include <sys/socket.h>

int connect(int sockfd, struct sockaddr *serv_addr, int addrlen);
```

这个函数成功的时候返回0, 失败的时候返回-1.

sockfd 是我们的好邻居 socket file descriptor，如同 socket() 调用所返回的，serv_addr 是一个 struct sockaddr，包含了目的 port 及 IP 地址，而 addrlen 是以 byte 为单位的 server 地址结构之长度。

我们有个示例，这边我们用 socket 连接到 ＂www.example.com＂ 的 port 3490：

```cpp
struct addrinfo hints, *res;
int sockfd;

// 首先，用 getaddrinfo() 载入 address structs：

memset(&hints, 0, sizeof hints);
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_STREAM;

getaddrinfo("www.example.com", "3490", &hints, &res);

// 建立一个 socket：

sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

// connect!
connect(sockfd, res->ai_addr, res->ai_addrlen);
```

我们无需调用bind，只需要关注服务端的port，kernal会自动帮我们设置local port。socket描述符如下：(x:y, serv_addr.sin_addr: serv_addr.sin_port)，其中x是客户端的IP地址，y是临时分配的端口，它唯一的确定了客户端主机上的进程。

### 2.4.4 open_clientfd函数

我们可以把socket和connect包装成open_clientfd的函数：

```
int open_clientfd(char *hostname, int port)
```

成功的话是文件描述符，Unix出错是-1，DNS出错是-2。

```c
/*
 * open_clientfd - open connection to server at <hostname, port>
 *   and return a socket descriptor ready for reading and writing.
 *   Returns -1 and sets errno on Unix error.
 *   Returns -2 and sets h_errno on DNS (gethostbyname) error.
 */
/* $begin open_clientfd */
int open_clientfd(char *hostname, int port)
{
    int clientfd;
    struct hostent *hp;
    struct sockaddr_in serveraddr;
		// 创建套接字描述符
    if ((clientfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        return -1; /* check errno for cause of error */
	
    /* Fill in the server's IP address and port */
    // 为服务器检索DNS主机条目，拷贝主机条目中的第一个IP地址到服务器的套接字地址结构
    if ((hp = gethostbyname(hostname)) == NULL)
        return -2; /* check h_errno for cause of error */
    bzero((char *) &serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    bcopy((char *)hp->h_addr_list[0],
          (char *)&serveraddr.sin_addr.s_addr, hp->h_length);
  	// 初始化套接字地址结构
    serveraddr.sin_port = htons(port);

    /* Establish a connection with the server */
    if (connect(clientfd, (SA *) &serveraddr, sizeof(serveraddr)) < 0)
        return -1;
    // 返回套接字描述符到客户端，客户端可以使用unix I/O和服务器来通信了
    return clientfd;
}
/* $end open_clientfd */
```

### 2.4.5 bind函数：What port am I on？

服务端调用，绑定端口，客户端无需调用，会自动分配端口。

```
#include <sys/socket.h>

int bind(int sockfd, const struct sockaddr* myaddr, socklen_t addrlen)
```

*sockfd* 是 socket() 传回的 socket file descriptor。*my_addr* 是指向包含你的地址资料丶名称及 IP address 的 struct sockaddr 之指针。*addrlen* 是以 byte 为单位的地址长度。

我们来看一个示例，它将 socket bind（绑定）到运行程序的主机上，port 是 3490：

```cpp
struct addrinfo hints, *res;
int sockfd;

// 首先，用 getaddrinfo() 载入地址结构：

memset(&hints, 0, sizeof hints);
hints.ai_family = AF_UNSPEC; // use IPv4 or IPv6, whichever
hints.ai_socktype = SOCK_STREAM;
hints.ai_flags = AI_PASSIVE; // fill in my IP for me

getaddrinfo(NULL, "3490", &hints, &res);

// 建立一个 socket：

sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

// 将 socket bind 到我们传递给 getaddrinfo() 的 port：

bind(sockfd, res->ai_addr, res->ai_addrlen);
```

bind() 在错误时也会返回 -1，并将 errno 设置为该错误的值。

### 2.4.6 listen函数，有人会调用我吗？

服务端调用。

客户端是发起连接请求的主动实体，服务端等待客户端的连接，socket函数创建的描述符对应于主动套接字(active socket),存在于客户端。

```
#include <sys/socket.h>

int listen(int sockfd, int backlog)
```

*sockfd* 是来自 socket() system call 的一般 socket file descriptor。*backlog* 是进入的队列（incoming queue）中所允许的连接数目。这代表什麽意思呢？好的，进入的连接将会在这个队列中排队等待，直到你 accept() 它们（请见下节），而这限制了排队的数量。多数的系统默认将这个数值限制为 20；你或许可以一开始就将它设置为 5 或 10。

再来，如同往常，listen() 会返回 -1 并在错误时设置 errno。

好的，你可能会想像，我们需要在调用 listen() 以前调用 bind()，让 server 可以在指定的 port 上运行。［你必须能告诉你的好朋友要连接到哪一个 port！］所以如果你正在 listen 进入的连接，你会运行的 system call 顺序是：

```
getaddrinfo();
socket();
bind();
listen();
/* accept() 从这里开始 */
```

listen函数把sockfd从主动套接字转换为监听套接字，用于接受来自客户端的请求。

### 2.4.7 open_listenfd函数

我们把socket，bind和listen函数结合成一个叫做open_listenfd函数。

```c
/*
 * open_listenfd - open and return a listening socket on port
 *     Returns -1 and sets errno on Unix error.
 */
/* $begin open_listenfd */
int open_listenfd(int port)
{
    int listenfd, optval=1;
    struct sockaddr_in serveraddr;

    /* Create a socket descriptor */
    if ((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        return -1;

    /* Eliminates "Address already in use" error from bind. */
    if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR,
                   (const void *)&optval , sizeof(int)) < 0)
        return -1;

    /* Listenfd will be an endpoint for all requests to port
       on any IP address for this host */
    bzero((char *) &serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    serveraddr.sin_port = htons((unsigned short)port);
    if (bind(listenfd, (SA *)&serveraddr, sizeof(serveraddr)) < 0)
        return -1;

    /* Make it a listening socket ready to accept connection requests */
    if (listen(listenfd, LISTENQ) < 0)
        return -1;
    return listenfd;
}
/* $end open_listenfd */
```

### 2.4.8 accept函数

很远的人会试着 connect() 到你的电脑正在 listen() 的 port。他们的连接会排队等待被 accept()。你调用 accept()，并告诉它要取得搁置的（pending）连接。它会返回专属这个连接的一个新 socket file descriptor 给你！那是对的，你突然有了**两个 *socket file descriptor***！原本的 socket file descriptor 仍然正在 listen 之後的连线，而新建立的 socket file descriptor 则是在最後要准备给 send() 与 recv() 用的。

```cpp
#include <sys/types.h>
#include <sys/socket.h>

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

*sockfd* 是正在进行 listen() 的 socket descriptor。很简单，*addr* 通常是一个指向 local struct sockaddr_storage 的指针，关於进来的连接将往哪里去的资料［而你可以用它来得知是哪一台主机从哪一个 port 调用你的］。*addrlen* 是一个 local 的整数变量，应该在将它的地址传递给 accept() 以前，将它设置为 sizeof(struct sockaddr_storage)。accept() 不会存放更多的 bytes（字节）到 *addr*。若它存放了较少的 bytes 进去，它会改变 *addrlen* 的值来表示。

有想到吗？accept() 在错误发生时返回 -1 并设置 errno。

跟以前一样，用一段代码示例会比较好吸收，所以这里有一段示例程供你细读：

```cpp
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define MYPORT "3490" // 使用者将连接的 port
#define BACKLOG 10 // 在队列中可以有多少个连接在等待

int main(void)
{
　　struct sockaddr_storage their_addr;
　　socklen_t addr_size;
　　struct addrinfo hints, *res;
　　int sockfd, new_fd;

　　// !! 不要忘了帮这些调用做错误检查 !!

　　// 首先，使用 getaddrinfo() 载入 address struct：

　　memset(&hints, 0, sizeof hints);
　　hints.ai_family = AF_UNSPEC; // 使用 IPv4 或 IPv6，都可以
　　hints.ai_socktype = SOCK_STREAM;
　　hints.ai_flags = AI_PASSIVE; // 帮我填上我的 IP 

　　getaddrinfo(NULL, MYPORT, &hints, &res);

　　// 产生一个 socket，bind socket，并 listen socket：

　　sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
　　bind(sockfd, res->ai_addr, res->ai_addrlen);
　　listen(sockfd, BACKLOG);

　　// 现在接受一个进入的连接：

　　addr_size = sizeof their_addr;
　　new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &addr_size);

　　// 准备好与 new_fd 这个 socket descriptor 进行沟通！
```

一样，我们会将 *new_fd* socket descriptor 用於 send() 与 recv() 调用。若你只是要取得一个连接，你可以用 close() 关闭正在 listen 的*sockfd*，以避免有更多的连接进入同一个 port，若你有这个需要的话。

我们再次来区分下监听描述符和连接描述符：前者是作为客户端连接请求的一个端点，被创建一次，服务于整个生命周期。后者每次请求都会创建。区分的目的是用来建立并发服务器，同时与很多客户端连接。

<img src="https://tva1.sinaimg.cn/large/006tNbRwgy1gain6bbladj30wc0k043d.jpg" alt="image-20200102233736238" style="zoom:50%;" />

### 2.4.9 send() 与 recv()

这两个用来通讯的函数是透过 stream socket 或 connected datagram ssocket。若你想要使用常规的 unconnected datagram socket，你会需要参考底下的 sendto() 及 recvfrom() 的章节。

send() 调用：

```
int send(int sockfd, const void *msg, int len, int flags);
```

*sockfd* 是你想要送资料过去的 socket descriptor［不论它是不是 socket() 返回的，或是你用 accept() 取得的］。*msg* 是一个指向你想要传送资料之指标，而 *len* 是以 byte 为单位的资料长度。而 *flags* 设置为 0 就好。

一些示例代码如下：

```
char *msg = "Beej was here!";
int len, bytes_sent;
.
.
.
len = strlen(msg);
bytes_sent = send(sockfd, msg, len, 0);
.
.
.
```

send() 会返回实际有送出的 byte 数目，这可能会少於你所要传送的数目！有时候你告诉 send() 要送整笔的资料，而它就是无法处理这麽多资料。它只会尽量将资料送出，并认为你之後会再次送出剩下没送出的部分。

要记住，如果 send() 返回的值与 *len* 的值不符合的话，你就需要再送出字串剩下的部分。好消息是：如果数据包很小［比 1K 还要小这类的］，或许有机会一次就送出全部的东西。

一样，错误时会返回 -1，并将 errno 设置为错误码（error number）。

recv() 调用在许多地方都是类似的：

```
int recv(int sockfd, void *buf, int len, int flags);
```

*sockfd* 是要读取的 socket descriptor，*buf* 是要记录读到资料的缓冲区（buffer），*len* 是缓冲区的最大长度，而 *flags* 可以再设置为 0。

recv() 返回实际读到并写入到缓冲区的 byte 数目，而错误时返回 -1［并设置相对的 errno］。

等等！ recv() 会返回 0，这只能表示一件事情：远端那边已经关闭了你的连接！recv() 返回 0 的值是让你知道这件事情。

这样很简单，不是吗？你现在可以送回数据，并往 stream sockets 迈进！嘻嘻！你是 UNIX 网路程序员了。

### 2.4.10 close() 与 shutdown()

关闭你 socket descriptor 的连接，这很简单，你只要使用常规的 UNIX file descriptor close() 函数：

```
close(sockfd);
```

这会避免对 socket 做更多的读写。任何想要对这个远端的 socket 进行读写的人都会收到错误。

如果你想要能多点控制 socket 如何关闭，可以使用 shutdown() 函数。它让你可以切断单向的通信，或者双向［就像是 close() 所做的］，这是函数原型：

```
int shutdown(int sockfd, int how);
```

*sockfd* 是你想要 shutdown 的 socket file descriptor，而 *how* 是下列其中一个值：

```
0 不允许再接收数据
1 不允许再传送数据
2 不允许再传送与接收数据［就像 close()］
```

shutdown() 成功时返回 0，而错误时返回 -1（设置相对的 errno）。

若你在 unconnected datagram socket 上使用 shutdown()，它只会单纯的让 socket 无法再进行 send() 与 recv() 调用［要记住你只能在有 connect() 到 datagram socket 的时候使用］。

重要的是 shutdown() 实际上没有关闭 file descriptor，它只是改变了它的可用性。如果要释放 socket descriptor，你还是需要使用 close()。

### 2.4.11 echo客户端和服务端

这个 server 所做的事情就是透过 stream connection（串流连接）送出"Hello, World!\n"字符串。你所需要做就是用一个窗口来测试执行 server，并用另一个窗口来 telnet 到 server：

$ telnet remotehostname 3490

```c
/*
** server.c － 展示一个stream socket server
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>
#define PORT "3490" // 提供给用戶连接的 port
#define BACKLOG 10 // 有多少个特定的连接队列（pending connections queue）

void sigchld_handler(int s)
{
  while(waitpid(-1, NULL, WNOHANG) > 0);
}

// 取得 sockaddr，IPv4 或 IPv6：
void *get_in_addr(struct sockaddr *sa)
{
  if (sa->sa_family == AF_INET) {
    return &(((struct sockaddr_in*)sa)->sin_addr);
  }
  return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(void)
{
  int sockfd, new_fd; // 在 sock_fd 进行 listen，new_fd 是新的连接
  struct addrinfo hints, *servinfo, *p;
  struct sockaddr_storage their_addr; // 连接者的地址资料
  socklen_t sin_size;
  struct sigaction sa;
  int yes=1;
  char s[INET6_ADDRSTRLEN];
  int rv;

  memset(&hints, 0, sizeof hints);
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE; // 使用我的 IP

  if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
    return 1;
  }

  // 以循环找出全部的结果，并绑定（bind）到第一个能用的结果
  for(p = servinfo; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype,
      p->ai_protocol)) == -1) {
      perror("server: socket");
      continue;
    }

    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
        sizeof(int)) == -1) {
      perror("setsockopt");
      exit(1);
    }

    if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      close(sockfd);
      perror("server: bind");
      continue;
    }

    break;
  }

  if (p == NULL) {
    fprintf(stderr, "server: failed to bind\n");
    return 2;
  }

  freeaddrinfo(servinfo); // 全部都用这个 structure

  if (listen(sockfd, BACKLOG) == -1) {
    perror("listen");
    exit(1);
  }

  sa.sa_handler = sigchld_handler; // 收拾全部死掉的 processes
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;

  if (sigaction(SIGCHLD, &sa, NULL) == -1) {
    perror("sigaction");
    exit(1);
  }

  printf("server: waiting for connections...\n");

  while(1) { // 主要的 accept() 循环
  
  sin_size = sizeof their_addr;
    new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);

    if (new_fd == -1) {
      perror("accept");
      continue;
    }

    inet_ntop(their_addr.ss_family,
    get_in_addr((struct sockaddr *)&their_addr),
      s, sizeof s);
    printf("server: got connection from %s\n", s);
 
    if (!fork()) { // 这个是 child process
      close(sockfd); // child 不需要 listener

      if (send(new_fd, "Hello, world!", 13, 0) == -1)
        perror("send");

      close(new_fd);

      exit(0);
    }
    close(new_fd); // parent 不需要这个
  }

  return 0;
}
```

client 所需要做的就是：连线到你在命令行所指定的主机 3490 port，接着，client 会收到 server 送回的字符串。

```cpp
/*
/*
** client.c -- 一个 stream socket client 的 demo
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define PORT "3490" // Client 所要连接的 port
#define MAXDATASIZE 100 // 我们一次可以收到的最大字节数量（number of bytes）

// 取得 IPv4 或 IPv6 的 sockaddr：
void *get_in_addr(struct sockaddr *sa)
{
　　if (sa->sa_family == AF_INET) {
　　　　return &(((struct sockaddr_in*)sa)->sin_addr);
　　}

　　return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(int argc, char *argv[])
{
　　int sockfd, numbytes;
　　char buf[MAXDATASIZE];
　　struct addrinfo hints, *servinfo, *p;
　　int rv;
　　char s[INET6_ADDRSTRLEN];

　　if (argc != 2) {
　　　　fprintf(stderr,"usage: client hostname\n");
　　　　exit(1);
　　}

　　memset(&hints, 0, sizeof hints);
　　hints.ai_family = AF_UNSPEC;
　　hints.ai_socktype = SOCK_STREAM;

　　if ((rv = getaddrinfo(argv[1], PORT, &hints, &servinfo)) != 0) {
　　　　fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
　　　　return 1;
　　}

　　// 用循环取得全部的结果，并先连接到能成功连接的
　　for(p = servinfo; p != NULL; p = p->ai_next) {
　　　　if ((sockfd = socket(p->ai_family, p->ai_socktype,
　　　　　　p->ai_protocol)) == -1) {
　　　　　　perror("client: socket");
　　　　　　continue;
　　　　}

　　　　if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
　　　　　　close(sockfd);
　　　　　　perror("client: connect");
　　　　　　continue;
　　　　}

　　　　break;
　　}

　　if (p == NULL) {
　　　　fprintf(stderr, "client: failed to connect\n");
　　　　return 2;
　　}

　　inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof s);

　　printf("client: connecting to %s\n", s);

　　freeaddrinfo(servinfo); // 全部皆以这个 structure 完成

　　if ((numbytes = recv(sockfd, buf, MAXDATASIZE-1, 0)) == -1) {
　　　　perror("recv");
　　　　exit(1);
　　}

　　buf[numbytes] = '\0';
　　printf("client: received '%s'\n",buf);

　　close(sockfd);
　　return 0;
}
```

要注意的是，你如果没有在运行 client 以前先启动 server 的话，connect()会返回 ＂Connection refused＂，这很有帮助。

## 2.5 web服务器

我们将在这一节尝试实现一个简单的web服务器。里面需要牵涉到html，http协议，然后就是www服务器。

先来看CSAPP的实现：

```cpp
/* $begin tinymain */
/*
 * tiny.c - A simple, iterative HTTP/1.0 Web server that uses the 
 *     GET method to serve static and dynamic content.
 */
#include "csapp.h"

void doit(int fd);
void read_requesthdrs(rio_t *rp);
int parse_uri(char *uri, char *filename, char *cgiargs);
void serve_static(int fd, char *filename, int filesize);
void get_filetype(char *filename, char *filetype);
void serve_dynamic(int fd, char *filename, char *cgiargs);
void clienterror(int fd, char *cause, char *errnum, 
		 char *shortmsg, char *longmsg);

int main(int argc, char **argv) 
{
    int listenfd, connfd, port, clientlen;
    struct sockaddr_in clientaddr;

    /* Check command line args */
    if (argc != 2) {
	fprintf(stderr, "usage: %s <port>\n", argv[0]);
	exit(1);
    }
    port = atoi(argv[1]);

    listenfd = Open_listenfd(port);
    while (1) {
	clientlen = sizeof(clientaddr);
  // Accept封装了accept
	connfd = Accept(listenfd, (SA *)&clientaddr, &clientlen); //line:netp:tiny:accept
	// 处理http事务
  doit(connfd);                                             //line:netp:tiny:doit
	Close(connfd);                                            //line:netp:tiny:close
    }
}
/* $end tinymain */

/*
 * doit - handle one HTTP request/response transaction
 */
/* $begin doit */
void doit(int fd) 
{
    int is_static;
    struct stat sbuf;
    char buf[MAXLINE], method[MAXLINE], uri[MAXLINE], version[MAXLINE];
    char filename[MAXLINE], cgiargs[MAXLINE];
    rio_t rio;
  
    /* Read request line and headers */
    Rio_readinitb(&rio, fd);
    Rio_readlineb(&rio, buf, MAXLINE);                   //line:netp:doit:readrequest
    // 解析请求行
  	sscanf(buf, "%s %s %s", method, uri, version);       //line:netp:doit:parserequest
    if (strcasecmp(method, "GET")) {                     //line:netp:doit:beginrequesterr
       clienterror(fd, method, "501", "Not Implemented",
                "Tiny does not implement this method");
        return;
    }                                                    //line:netp:doit:endrequesterr
    read_requesthdrs(&rio);                              //line:netp:doit:readrequesthdrs

    /* Parse URI from GET request */
    is_static = parse_uri(uri, filename, cgiargs);       //line:netp:doit:staticcheck
    if (stat(filename, &sbuf) < 0) {                     //line:netp:doit:beginnotfound
	clienterror(fd, filename, "404", "Not found",
		    "Tiny couldn't find this file");
	return;
    }                                                    //line:netp:doit:endnotfound

    if (is_static) { /* Serve static content */          
	if (!(S_ISREG(sbuf.st_mode)) || !(S_IRUSR & sbuf.st_mode)) { //line:netp:doit:readable
	    clienterror(fd, filename, "403", "Forbidden",
			"Tiny couldn't read the file");
	    return;
	}
	serve_static(fd, filename, sbuf.st_size);        //line:netp:doit:servestatic
    }
    else { /* Serve dynamic content */
	if (!(S_ISREG(sbuf.st_mode)) || !(S_IXUSR & sbuf.st_mode)) { //line:netp:doit:executable
	    clienterror(fd, filename, "403", "Forbidden",
			"Tiny couldn't run the CGI program");
	    return;
	}
	serve_dynamic(fd, filename, cgiargs);            //line:netp:doit:servedynamic
    }
}
/* $end doit */

/*
 * read_requesthdrs - read and parse HTTP request headers
 */
/* $begin read_requesthdrs */
void read_requesthdrs(rio_t *rp) 
{
    char buf[MAXLINE];

    Rio_readlineb(rp, buf, MAXLINE);
  	// \r\n表示终止请求
    while(strcmp(buf, "\r\n")) {          //line:netp:readhdrs:checkterm
	Rio_readlineb(rp, buf, MAXLINE);
	printf("%s", buf);
    }
    return;
}
/* $end read_requesthdrs */

/*
 * parse_uri - parse URI into filename and CGI args
 *             return 0 if dynamic content, 1 if static
 */
/* $begin parse_uri */
int parse_uri(char *uri, char *filename, char *cgiargs) 
{
    char *ptr;

    if (!strstr(uri, "cgi-bin")) {  /* Static content */ //line:netp:parseuri:isstatic
	strcpy(cgiargs, "");                             //line:netp:parseuri:clearcgi
	strcpy(filename, ".");                           //line:netp:parseuri:beginconvert1
	strcat(filename, uri);                           //line:netp:parseuri:endconvert1
	if (uri[strlen(uri)-1] == '/')                   //line:netp:parseuri:slashcheck
	    strcat(filename, "home.html");               //line:netp:parseuri:appenddefault
	return 1;
    }
    else {  /* Dynamic content */                        //line:netp:parseuri:isdynamic
	ptr = index(uri, '?');                           //line:netp:parseuri:beginextract
	if (ptr) {
	    strcpy(cgiargs, ptr+1);
	    *ptr = '\0';
	}
	else 
	    strcpy(cgiargs, "");                         //line:netp:parseuri:endextract
	strcpy(filename, ".");                           //line:netp:parseuri:beginconvert2
	strcat(filename, uri);                           //line:netp:parseuri:endconvert2
	return 0;
    }
}
/* $end parse_uri */

/*
 * serve_static - copy a file back to the client 
 */
/* $begin serve_static */
void serve_static(int fd, char *filename, int filesize) 
{
    int srcfd;
    char *srcp, filetype[MAXLINE], buf[MAXBUF];
 
    /* Send response headers to client */
    get_filetype(filename, filetype);       //line:netp:servestatic:getfiletype
    sprintf(buf, "HTTP/1.0 200 OK\r\n");    //line:netp:servestatic:beginserve
    sprintf(buf, "%sServer: Tiny Web Server\r\n", buf);
    sprintf(buf, "%sContent-length: %d\r\n", buf, filesize);
    sprintf(buf, "%sContent-type: %s\r\n\r\n", buf, filetype);
    Rio_writen(fd, buf, strlen(buf));       //line:netp:servestatic:endserve

    /* Send response body to client */
  	// 将内容拷贝到已连接描述符fd
  	// 打开文件名，获取描述符
    srcfd = Open(filename, O_RDONLY, 0);    //line:netp:servestatic:open
  	// 将请求文件映射到虚拟存储器空间
    srcp = Mmap(0, filesize, PROT_READ, MAP_PRIVATE, srcfd, 0);//line:netp:servestatic:mmap
    // 关闭文件，如果关闭文件失败，将会内存泄露
  	Close(srcfd);                           //line:netp:servestatic:close
    // 发送到客户端，把文件拷贝到客户端的已连接文件描述符
  	Rio_writen(fd, srcp, filesize);         //line:netp:servestatic:write
    // 释放映射的虚拟存储器，避免内存泄露
  	Munmap(srcp, filesize);                 //line:netp:servestatic:munmap
}

/*
 * get_filetype - derive file type from file name
 */
void get_filetype(char *filename, char *filetype) 
{
    if (strstr(filename, ".html"))
	strcpy(filetype, "text/html");
    else if (strstr(filename, ".gif"))
	strcpy(filetype, "image/gif");
    else if (strstr(filename, ".jpg"))
	strcpy(filetype, "image/jpeg");
    else
	strcpy(filetype, "text/plain");
}  
/* $end serve_static */

/*
 * serve_dynamic - run a CGI program on behalf of the client
 */
/* $begin serve_dynamic */
void serve_dynamic(int fd, char *filename, char *cgiargs) 
{
    char buf[MAXLINE], *emptylist[] = { NULL };

    /* Return first part of HTTP response */
    sprintf(buf, "HTTP/1.0 200 OK\r\n"); 
    Rio_writen(fd, buf, strlen(buf));
    sprintf(buf, "Server: Tiny Web Server\r\n");
    Rio_writen(fd, buf, strlen(buf));
  
    if (Fork() == 0) { /* child */ //line:netp:servedynamic:fork
	/* Real server would set all CGI vars here */
	setenv("QUERY_STRING", cgiargs, 1); //line:netp:servedynamic:setenv
	Dup2(fd, STDOUT_FILENO);         /* Redirect stdout to client */ //line:netp:servedynamic:dup2
	Execve(filename, emptylist, environ); /* Run CGI program */ //line:netp:servedynamic:execve
    }
    Wait(NULL); /* Parent waits for and reaps child */ //line:netp:servedynamic:wait
}
/* $end serve_dynamic */

/*
 * clienterror - returns an error message to the client
 */
/* $begin clienterror */
void clienterror(int fd, char *cause, char *errnum, 
		 char *shortmsg, char *longmsg) 
{
    char buf[MAXLINE], body[MAXBUF];

    /* Build the HTTP response body */
    sprintf(body, "<html><title>Tiny Error</title>");
    sprintf(body, "%s<body bgcolor=""ffffff"">\r\n", body);
    sprintf(body, "%s%s: %s\r\n", body, errnum, shortmsg);
    sprintf(body, "%s<p>%s: %s\r\n", body, longmsg, cause);
    sprintf(body, "%s<hr><em>The Tiny Web server</em>\r\n", body);

    /* Print the HTTP response */
    sprintf(buf, "HTTP/1.0 %s %s\r\n", errnum, shortmsg);
    Rio_writen(fd, buf, strlen(buf));
    sprintf(buf, "Content-type: text/html\r\n");
    Rio_writen(fd, buf, strlen(buf));
    sprintf(buf, "Content-length: %d\r\n\r\n", (int)strlen(body));
    Rio_writen(fd, buf, strlen(buf));
    Rio_writen(fd, body, strlen(body));
}
/* $end clienterror */
```



来自：https://github.com/shenfeng/tiny-web-server

```cpp
#include <arpa/inet.h>          /* inet_ntoa */
#include <signal.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sendfile.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define LISTENQ  1024  /* second argument to listen() */
#define MAXLINE 1024   /* max length of a line */
#define RIO_BUFSIZE 1024

typedef struct {
    int rio_fd;                 /* descriptor for this buf */
    int rio_cnt;                /* unread byte in this buf */
    char *rio_bufptr;           /* next unread byte in this buf */
    char rio_buf[RIO_BUFSIZE];  /* internal buffer */
} rio_t;

/* Simplifies calls to bind(), connect(), and accept() */
typedef struct sockaddr SA;

typedef struct {
    char filename[512];
    off_t offset;              /* for support Range */
    size_t end;
} http_request;

typedef struct {
    const char *extension;
    const char *mime_type;
} mime_map;

mime_map meme_types [] = {
    {".css", "text/css"},
    {".gif", "image/gif"},
    {".htm", "text/html"},
    {".html", "text/html"},
    {".jpeg", "image/jpeg"},
    {".jpg", "image/jpeg"},
    {".ico", "image/x-icon"},
    {".js", "application/javascript"},
    {".pdf", "application/pdf"},
    {".mp4", "video/mp4"},
    {".png", "image/png"},
    {".svg", "image/svg+xml"},
    {".xml", "text/xml"},
    {NULL, NULL},
};

char *default_mime_type = "text/plain";

void rio_readinitb(rio_t *rp, int fd){
    rp->rio_fd = fd;
    rp->rio_cnt = 0;
    rp->rio_bufptr = rp->rio_buf;
}

ssize_t writen(int fd, void *usrbuf, size_t n){
    size_t nleft = n;
    ssize_t nwritten;
    char *bufp = usrbuf;

    while (nleft > 0){
        if ((nwritten = write(fd, bufp, nleft)) <= 0){
            if (errno == EINTR)  /* interrupted by sig handler return */
                nwritten = 0;    /* and call write() again */
            else
                return -1;       /* errorno set by write() */
        }
        nleft -= nwritten;
        bufp += nwritten;
    }
    return n;
}


/*
 * rio_read - This is a wrapper for the Unix read() function that
 *    transfers min(n, rio_cnt) bytes from an internal buffer to a user
 *    buffer, where n is the number of bytes requested by the user and
 *    rio_cnt is the number of unread bytes in the internal buffer. On
 *    entry, rio_read() refills the internal buffer via a call to
 *    read() if the internal buffer is empty.
 */
/* $begin rio_read */
static ssize_t rio_read(rio_t *rp, char *usrbuf, size_t n){
    int cnt;
    while (rp->rio_cnt <= 0){  /* refill if buf is empty */

        rp->rio_cnt = read(rp->rio_fd, rp->rio_buf,
                           sizeof(rp->rio_buf));
        if (rp->rio_cnt < 0){
            if (errno != EINTR) /* interrupted by sig handler return */
                return -1;
        }
        else if (rp->rio_cnt == 0)  /* EOF */
            return 0;
        else
            rp->rio_bufptr = rp->rio_buf; /* reset buffer ptr */
    }

    /* Copy min(n, rp->rio_cnt) bytes from internal buf to user buf */
    cnt = n;
    if (rp->rio_cnt < n)
        cnt = rp->rio_cnt;
    memcpy(usrbuf, rp->rio_bufptr, cnt);
    rp->rio_bufptr += cnt;
    rp->rio_cnt -= cnt;
    return cnt;
}

/*
 * rio_readlineb - robustly read a text line (buffered)
 */
ssize_t rio_readlineb(rio_t *rp, void *usrbuf, size_t maxlen){
    int n, rc;
    char c, *bufp = usrbuf;

    for (n = 1; n < maxlen; n++){
        if ((rc = rio_read(rp, &c, 1)) == 1){
            *bufp++ = c;
            if (c == '\n')
                break;
        } else if (rc == 0){
            if (n == 1)
                return 0; /* EOF, no data read */
            else
                break;    /* EOF, some data was read */
        } else
            return -1;    /* error */
    }
    *bufp = 0;
    return n;
}

void format_size(char* buf, struct stat *stat){
    if(S_ISDIR(stat->st_mode)){
        sprintf(buf, "%s", "[DIR]");
    } else {
        off_t size = stat->st_size;
        if(size < 1024){
            sprintf(buf, "%lu", size);
        } else if (size < 1024 * 1024){
            sprintf(buf, "%.1fK", (double)size / 1024);
        } else if (size < 1024 * 1024 * 1024){
            sprintf(buf, "%.1fM", (double)size / 1024 / 1024);
        } else {
            sprintf(buf, "%.1fG", (double)size / 1024 / 1024 / 1024);
        }
    }
}

void handle_directory_request(int out_fd, int dir_fd, char *filename){
    char buf[MAXLINE], m_time[32], size[16];
    struct stat statbuf;
    sprintf(buf, "HTTP/1.1 200 OK\r\n%s%s%s%s%s",
            "Content-Type: text/html\r\n\r\n",
            "<html><head><style>",
            "body{font-family: monospace; font-size: 13px;}",
            "td {padding: 1.5px 6px;}",
            "</style></head><body><table>\n");
    writen(out_fd, buf, strlen(buf));
    DIR *d = fdopendir(dir_fd);
    struct dirent *dp;
    int ffd;
    while ((dp = readdir(d)) != NULL){
        if(!strcmp(dp->d_name, ".") || !strcmp(dp->d_name, "..")){
            continue;
        }
        if ((ffd = openat(dir_fd, dp->d_name, O_RDONLY)) == -1){
            perror(dp->d_name);
            continue;
        }
        fstat(ffd, &statbuf);
        strftime(m_time, sizeof(m_time),
                 "%Y-%m-%d %H:%M", localtime(&statbuf.st_mtime));
        format_size(size, &statbuf);
        if(S_ISREG(statbuf.st_mode) || S_ISDIR(statbuf.st_mode)){
            char *d = S_ISDIR(statbuf.st_mode) ? "/" : "";
            sprintf(buf, "<tr><td><a href=\"%s%s\">%s%s</a></td><td>%s</td><td>%s</td></tr>\n",
                    dp->d_name, d, dp->d_name, d, m_time, size);
            writen(out_fd, buf, strlen(buf));
        }
        close(ffd);
    }
    sprintf(buf, "</table></body></html>");
    writen(out_fd, buf, strlen(buf));
    closedir(d);
}

static const char* get_mime_type(char *filename){
    char *dot = strrchr(filename, '.');
    if(dot){ // strrchar Locate last occurrence of character in string
        mime_map *map = meme_types;
        while(map->extension){
            if(strcmp(map->extension, dot) == 0){
                return map->mime_type;
            }
            map++;
        }
    }
    return default_mime_type;
}


int open_listenfd(int port){
    int listenfd, optval=1;
    struct sockaddr_in serveraddr;

    /* Create a socket descriptor */
    if ((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        return -1;

    /* Eliminates "Address already in use" error from bind. */
    if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR,
                   (const void *)&optval , sizeof(int)) < 0)
        return -1;

    // 6 is TCP's protocol number
    // enable this, much faster : 4000 req/s -> 17000 req/s
    if (setsockopt(listenfd, 6, TCP_CORK,
                   (const void *)&optval , sizeof(int)) < 0)
        return -1;

    /* Listenfd will be an endpoint for all requests to port
       on any IP address for this host */
    memset(&serveraddr, 0, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    serveraddr.sin_port = htons((unsigned short)port);
    if (bind(listenfd, (SA *)&serveraddr, sizeof(serveraddr)) < 0)
        return -1;

    /* Make it a listening socket ready to accept connection requests */
    if (listen(listenfd, LISTENQ) < 0)
        return -1;
    return listenfd;
}

void url_decode(char* src, char* dest, int max) {
    char *p = src;
    char code[3] = { 0 };
    while(*p && --max) {
        if(*p == '%') {
            memcpy(code, ++p, 2);
            *dest++ = (char)strtoul(code, NULL, 16);
            p += 2;
        } else {
            *dest++ = *p++;
        }
    }
    *dest = '\0';
}

void parse_request(int fd, http_request *req){
    rio_t rio;
    char buf[MAXLINE], method[MAXLINE], uri[MAXLINE];
    req->offset = 0;
    req->end = 0;              /* default */

    rio_readinitb(&rio, fd);
    rio_readlineb(&rio, buf, MAXLINE);
    sscanf(buf, "%s %s", method, uri); /* version is not cared */
    /* read all */
    while(buf[0] != '\n' && buf[1] != '\n') { /* \n || \r\n */
        rio_readlineb(&rio, buf, MAXLINE);
        if(buf[0] == 'R' && buf[1] == 'a' && buf[2] == 'n'){
            sscanf(buf, "Range: bytes=%lu-%lu", &req->offset, &req->end);
            // Range: [start, end]
            if( req->end != 0) req->end ++;
        }
    }
    char* filename = uri;
    if(uri[0] == '/'){
        filename = uri + 1;
        int length = strlen(filename);
        if (length == 0){
            filename = ".";
        } else {
            for (int i = 0; i < length; ++ i) {
                if (filename[i] == '?') {
                    filename[i] = '\0';
                    break;
                }
            }
        }
    }
    url_decode(filename, req->filename, MAXLINE);
}


void log_access(int status, struct sockaddr_in *c_addr, http_request *req){
    printf("%s:%d %d - %s\n", inet_ntoa(c_addr->sin_addr),
           ntohs(c_addr->sin_port), status, req->filename);
}

void client_error(int fd, int status, char *msg, char *longmsg){
    char buf[MAXLINE];
    sprintf(buf, "HTTP/1.1 %d %s\r\n", status, msg);
    sprintf(buf + strlen(buf),
            "Content-length: %lu\r\n\r\n", strlen(longmsg));
    sprintf(buf + strlen(buf), "%s", longmsg);
    writen(fd, buf, strlen(buf));
}

void serve_static(int out_fd, int in_fd, http_request *req,
                  size_t total_size){
    char buf[256];
    if (req->offset > 0){
        sprintf(buf, "HTTP/1.1 206 Partial\r\n");
        sprintf(buf + strlen(buf), "Content-Range: bytes %lu-%lu/%lu\r\n",
                req->offset, req->end, total_size);
    } else {
        sprintf(buf, "HTTP/1.1 200 OK\r\nAccept-Ranges: bytes\r\n");
    }
    sprintf(buf + strlen(buf), "Cache-Control: no-cache\r\n");
    // sprintf(buf + strlen(buf), "Cache-Control: public, max-age=315360000\r\nExpires: Thu, 31 Dec 2037 23:55:55 GMT\r\n");

    sprintf(buf + strlen(buf), "Content-length: %lu\r\n",
            req->end - req->offset);
    sprintf(buf + strlen(buf), "Content-type: %s\r\n\r\n",
            get_mime_type(req->filename));

    writen(out_fd, buf, strlen(buf));
    off_t offset = req->offset; /* copy */
    while(offset < req->end){
        if(sendfile(out_fd, in_fd, &offset, req->end - req->offset) <= 0) {
            break;
        }
        printf("offset: %d \n\n", offset);
        close(out_fd);
        break;
    }
}

void process(int fd, struct sockaddr_in *clientaddr){
    printf("accept request, fd is %d, pid is %d\n", fd, getpid());
    http_request req;
    parse_request(fd, &req);

    struct stat sbuf;
    int status = 200, ffd = open(req.filename, O_RDONLY, 0);
    if(ffd <= 0){
        status = 404;
        char *msg = "File not found";
        client_error(fd, status, "Not found", msg);
    } else {
        fstat(ffd, &sbuf);
        if(S_ISREG(sbuf.st_mode)){
            if (req.end == 0){
                req.end = sbuf.st_size;
            }
            if (req.offset > 0){
                status = 206;
            }
            serve_static(fd, ffd, &req, sbuf.st_size);
        } else if(S_ISDIR(sbuf.st_mode)){
            status = 200;
            handle_directory_request(fd, ffd, req.filename);
        } else {
            status = 400;
            char *msg = "Unknow Error";
            client_error(fd, status, "Error", msg);
        }
        close(ffd);
    }
    log_access(status, clientaddr, &req);
}

int main(int argc, char** argv){
    struct sockaddr_in clientaddr;
    int default_port = 9999,
        listenfd,
        connfd;
    char buf[256];
    char *path = getcwd(buf, 256);
    socklen_t clientlen = sizeof clientaddr;
    if(argc == 2) {
        if(argv[1][0] >= '0' && argv[1][0] <= '9') {
            default_port = atoi(argv[1]);
        } else {
            path = argv[1];
            if(chdir(argv[1]) != 0) {
                perror(argv[1]);
                exit(1);
            }
        }
    } else if (argc == 3) {
        default_port = atoi(argv[2]);
        path = argv[1];
        if(chdir(argv[1]) != 0) {
            perror(argv[1]);
            exit(1);
        }
    }

    listenfd = open_listenfd(default_port);
    if (listenfd > 0) {
        printf("listen on port %d, fd is %d\n", default_port, listenfd);
    } else {
        perror("ERROR");
        exit(listenfd);
    }
    // Ignore SIGPIPE signal, so if browser cancels the request, it
    // won't kill the whole process.
    signal(SIGPIPE, SIG_IGN);

    for(int i = 0; i < 10; i++) {
        int pid = fork();
        if (pid == 0) {         //  child
            while(1){
                connfd = accept(listenfd, (SA *)&clientaddr, &clientlen);
                process(connfd, &clientaddr);
                close(connfd);
            }
        } else if (pid > 0) {   //  parent
            printf("child pid is %d\n", pid);
        } else {
            perror("fork");
        }
    }

    while(1){
        connfd = accept(listenfd, (SA *)&clientaddr, &clientlen);
        process(connfd, &clientaddr);
        close(connfd);
    }

    return 0;
}
```

## 2.6 socket高级编程

### 2.6.1 Blocking（阻塞）

你听过 blocking，只是它在这里代表什麽鬼东西呢？简而言之，＂block＂ 就是 ＂sleep（休眠）＂的技术术语。你在以前运行 **listener**时你可能有注意到，它只是在那边等，直到有数据包抵达。

很多函数都会 block，**accept()** 会 block，全部的 recv() 函数都会 block。原因是它们有权这麽做。当你先用 **socket()** 建立 socket descriptor 时，kernel（内核）会将它设置为 blocking。若你不想要 blocking socket，你必须调用 **fcntl()**：

```
#include <unistd.h>
#include <fcntl.h>
.
.
.
sockfd = socket(PF_INET, SOCK_STREAM, 0);
fcntl(sockfd, F_SETFL, O_NONBLOCK);
.
.
.
```

将 socket 设置为 non-blocking（非阻塞），你就能 ＂poll（轮询）＂socket 以取得数据。如果你试着读取 non-blocking socket，而 socket 没有数据时，函数就不会发生 block，而是返回 -1，并将 errno 设置为 EWOULDBLOCK。

然而，一般来说，这样 polling 是不好的想法。如果你让程序一直忙着查 socket 上是否有数据，则会浪费 CPU 的时间，这样是不合适的。比较漂亮的解法是利用下一节的 **select()** 来检查 socket 是否有数据需要读取。

### 2.6.2  select()－同步 I/O 多工

这个函数有点奇怪，不过它很好用。看看下面这个情况：如果你是一个 server，而你想要 listen 正在进来的连接，如同不断读取已建立的连接 socket 一样。

你说：没问题，只要用 **accept()** 及一对 **recv()** 就好了。

慢点，老兄！如果你在 **accept()** call 时发生了 blocking 该怎麽办呢？你要如何同时进行 **recv()** 呢？

＂那就使用 non-blocking socket！＂

不行！你不会想成为浪费 CPU 资源的罪人吧。

嗯，那有什麽好方法吗？

**select()** 授予你同时监视多个 sockets 的权力，它会告诉你哪些 sockets 已经有数据可以读取丶哪些 sockets 已经可以写入，如果你真的想知道，还会告诉你哪些 sockets 触发了例外。

即使 **select()** 相当有可移植性，不过却是监视 sockets 最慢的方法。一个比较可行的替代方案是 libevent [24] 或者其它类似的方法，封装全部的系统相依要素，用以取得 socket 的通知。

好了，不罗唆，下面我提供了 **select()** 的原型：

```cpp
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int select(int numfds, fd_set *readfds, fd_set *writefds,
           fd_set *exceptfds, struct timeval *timeout);
```

这个函数以 *readfds*丶*writefds* 及 *exceptfds* 监视 file descriptor（文件描述符）的 ＂sets（组）＂。如果你想要知道你是否能读取 standard input（标准输入）及某个 *sockfd* socket descriptor，只要将 file descriptor 0 与 *sockfd* 新增到 *readfds* set 中。*numfds* 参数应该要设置为 file descriptor 的最高值加 1。在这个例子中，应该要将 *numfds* 设置为 *sockfd+1*，因为它必定大於 standard input（0）。

当 **select()** 回传时，*readfds* 会被修改，用来反映你所设置的 file descriptors 中，哪些已经有数据可以读取，你可以用下列的**FD_ISSET()** macro（宏）来取得这些可读的 file descriptors。

在继续谈下去以前，我想要说说该如何控制这些 sets。

每个 sets 的型别都是 fd_set，下列是用来控制这个型别的 macro：

```
FD_SET(int fd, fd_set *set);     将 fd 新增到 set。
FD_CLR(int fd, fd_set *set);     从 set 移除 fd。
FD_ISSET(int fd, fd_set *set);   若 fd 在 set 中，返回 true。
FD_ZERO(fd_set *set);            将 set 整个清为零。
```


最後，这个令人困惑的 struct timeval 是什麽东西呢？

好，有时你不想要一直花时间在等人家送数据给你，或者明明没什麽事，却每 96 秒就要印出 ＂运行中 ...＂ 到终端（terminal），而这个 time structure 让你可以设置 timeout 的周期。

如果时间超过了，而 **select()** 还没有找到任何就绪的 file descriptor 时，它会回传，让你可以继续做其它事情。

struct timeval 的栏位如下：

```
struct timeval {
  int tv_sec; // 秒（second）
  int tv_usec; // 微秒（microseconds）
};
```


只要将 *tv_sec* 设置为要等待的秒数，并将 *tv_usec* 设置为要等待的微秒数。是的，就是微秒，不是毫秒。一毫秒有 1,000 微秒，而一秒有 1,000 毫秒。所以，一秒就有 1,000,000 微秒。

为什麽要用 ＂usec（微秒）＂ 呢？

＂u＂看起来很像我们用来表示 ＂micro（微）＂的希腊字母 μ（Mu）。还有，当函数回传时，会更新 *timeout*，用以表示还剩下多少时间。这个行为取决於你所使用的 Unix 而定。



译注： 因为有些系统平台的 select() 会修改 timeout 的值，而有些系统不会，所以如果要重复调用 select() 的话，每次都应该要重新设置 timeout 的值，以确保程序的行为可以符合预期。


哇！我们有微秒精度的计时器了！

是的，不过别依赖它。无论你将 struct timeval 设置的多小，你可能还要等待一小段 standard Unix timeslice（标准 Unix 时间片段）。

另一件有趣的事：如果你将 struct timeval 的栏位设置为 0，select() 会在轮询过 sets 中的每个 file descriptors 之後，就马上 timeout。如果你将 timeout 参数设置为 NULL，它就永远不会 timeout，并且陷入等待，直到至少一个 file descriptor 已经就绪（ready）。如果你不在乎等待时间，就在调用 **select()** 时将 timeout 参数设置为 NULL。

下列的代码片段 [25] 等待 2.5 秒後，就会出现 standard input（标准输入）所输入的东西：

```cpp
/*
** select.c -- a select() demo
*/
#include <stdio.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#define STDIN 0 // standard input 的 file descriptor
int main(void)
{
  struct timeval tv;
  fd_set readfds;

  tv.tv_sec = 2;
  tv.tv_usec = 500000;

  FD_ZERO(&readfds);
  FD_SET(STDIN, &readfds);

  // 不用管 writefds 与 exceptfds：
  select(STDIN+1, &readfds, NULL, NULL, &tv);

  if (FD_ISSET(STDIN, &readfds))
    printf("A key was pressed!\n");
  else
    printf("Timed out.\n");
  return 0;
}
```

如果你用一行缓冲区（buffer）的终端，那麽你从键盘输入数据後应该要尽快按下 Enter，否则程序就会发生 timeout。

你现在可能在想，这个方法用在需要等待数据的 datagram socket 上很好，而且你是对的：应该是不错的方法。

有些系统会用这个方式来使用 select()，而有些不行，如果你想要用它，你应该要参考你系统上的 man 使用手册说明看是否会有问题。

有些系统会更新 struct timeval 的时间，用来反映 select() 原本还剩下多少时间 timeout；不过有些却不会。如果你想要程序是可移植的，那就不要倚赖这个特性。［如果你需要追踪剩下的时间，可以使用 **gettimeofday()**，我知道这很令人失望，不过事实就是这样。］

如果在 read set 中的 socket 关闭连接，会怎样吗？

好的，这个例子的 **select()** 回传时，会在 socket descriptor set 中说明这个 socket 是 ＂ready to read（就绪可读）＂的。而当你真的用**recv()** 去读取这个 socket 时，**recv()** 则会回传 0 给你。这样你就能知道是 client 关闭连接了。

再次强调 **select()** 有趣的地方：如果你正在 listen() 一个 socket，你可以将这个 socket 的 file descriptor 放在 *readfds* set 中，用来检查是不是有新的连接。

我的朋友阿，这就是万能 **select()** 函数的速成说明。

不过，应观众要求，这里提供个有深度的范例，毫无疑问地，以前的简单范例和这个范例的难易度会有显着差距。不过你可以先看看，然後读後面的解释。

程序 [26] 的行为是简单的多用户聊天室 server，在一个窗口中运行 server，然後在其它多个窗口使用 **telnet** 连接到 server［＂**telnet hostname 9034**＂］。当你在其中一个 **telnet** session 中输入某些文字时，这些文字应该会在其它每个窗口上出现。

```cpp
/*
** selectserver.c -- 一个 cheezy 的多人聊天室 server
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PORT "9034" // 我们正在 listen 的 port

// 取得 sockaddr，IPv4 或 IPv6：
void *get_in_addr(struct sockaddr *sa)
{
  if (sa->sa_family == AF_INET) {
    return &(((struct sockaddr_in*)sa)->sin_addr);
  }

  return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(void)
{
  fd_set master; // master file descriptor 表
  fd_set read_fds; // 给 select() 用的暂时 file descriptor 表
  int fdmax; // 最大的 file descriptor 数目

  int listener; // listening socket descriptor
  int newfd; // 新接受的 accept() socket descriptor
  struct sockaddr_storage remoteaddr; // client address
  socklen_t addrlen;

  char buf[256]; // 储存 client 数据的缓冲区
  int nbytes;

  char remoteIP[INET6_ADDRSTRLEN];

  int yes=1; // 供底下的 setsockopt() 设置 SO_REUSEADDR
  int i, j, rv;

  struct addrinfo hints, *ai, *p;

  FD_ZERO(&master); // 清除 master 与 temp sets
  FD_ZERO(&read_fds);

  // 给我们一个 socket，并且 bind 它
  memset(&hints, 0, sizeof hints);
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  if ((rv = getaddrinfo(NULL, PORT, &hints, &ai)) != 0) {
    fprintf(stderr, "selectserver: %s\n", gai_strerror(rv));
    exit(1);
  }

  for(p = ai; p != NULL; p = p->ai_next) {
    listener = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
    if (listener < 0) {
      continue;
    }

    // 避开这个错误信息："address already in use"
    setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));

    if (bind(listener, p->ai_addr, p->ai_addrlen) < 0) {
      close(listener);
      continue;
    }

    break;
  }

  // 若我们进入这个判断式，则表示我们 bind() 失败
  if (p == NULL) {
    fprintf(stderr, "selectserver: failed to bind\n");
    exit(2);
  }
  freeaddrinfo(ai); // all done with this

  // listen
  if (listen(listener, 10) == -1) {
    perror("listen");
    exit(3);
  }

  // 将 listener 新增到 master set
  FD_SET(listener, &master);

  // 持续追踪最大的 file descriptor
  fdmax = listener; // 到此为止，就是它了

  // 主要循环
  for( ; ; ) {
    read_fds = master; // 复制 master

    if (select(fdmax+1, &read_fds, NULL, NULL, NULL) == -1) {
      perror("select");
      exit(4);
    }

    // 在现存的连接中寻找需要读取的数据
    for(i = 0; i <= fdmax; i++) {
      if (FD_ISSET(i, &read_fds)) { // 我们找到一个！！
        if (i == listener) {
          // handle new connections
          addrlen = sizeof remoteaddr;
          newfd = accept(listener,
            (struct sockaddr *)&remoteaddr,
            &addrlen);

          if (newfd == -1) {
            perror("accept");
          } else {
            FD_SET(newfd, &master); // 新增到 master set
            if (newfd > fdmax) { // 持续追踪最大的 fd
              fdmax = newfd;
            }
            printf("selectserver: new connection from %s on "
              "socket %d\n",
              inet_ntop(remoteaddr.ss_family,
                get_in_addr((struct sockaddr*)&remoteaddr),
                remoteIP, INET6_ADDRSTRLEN),
              newfd);
          }

        } else {
          // 处理来自 client 的数据
          if ((nbytes = recv(i, buf, sizeof buf, 0)) <= 0) {
            // got error or connection closed by client
            if (nbytes == 0) {
              // 关闭连接
              printf("selectserver: socket %d hung up\n", i);
            } else {
              perror("recv");
            }
            close(i); // bye!
            FD_CLR(i, &master); // 从 master set 中移除

          } else {
            // 我们从 client 收到一些数据
            for(j = 0; j <= fdmax; j++) {
              // 送给大家！
              if (FD_ISSET(j, &master)) {
                // 不用送给 listener 跟我们自己
                if (j != listener && j != i) {
                  if (send(j, buf, nbytes, 0) == -1) {
                    perror("send");
                  }
                }
              }
            }
          }
        } // END handle data from client
      } // END got new incoming connection
    } // END looping through file descriptors
  } // END for( ; ; )--and you thought it would never end!

  return 0;
}
```

我说过在代码中有两个 file descriptor sets：*master* 与 *read_fds*。前面的 *master* 记录全部现有连接的 socket descriptors，与正在 listen 新连接的 socket descriptor 一样。

我用 *master* 的理由是因为 **select()** 实际上会改变你传送过去的 set，用来反映目前就绪可读（ready for read）的 sockets。因为我必须在在两次的 **select()** calls 期间也能够持续追踪连接，所以我必须将这些数据安全地储存在某个地方。最後，我再将 *master* 复制到*read_fds*，并接着调用 **select()**。

可是这不就代表每当有新连接时，我就要将它新增到 *master set* 吗？是的！

而每次连接结束时，我们也要将它从 master set 中移除吗？是的，没有错。

我说过，我们要检查 listen 的 socket 是否就绪可读，如果可读，这代表我有一个待处理的连接，而且我要 **accept()** 这个连接，并将它新增到 *master* set。同样地，当 client 连接就绪可读且 **recv()** 返回 0 时，我们就能知道 client 关闭了连接，而我必须将这个 socket descriptor 从 master set 中移除。

若 client 的 **recv()** 返回非零的值，因而，我能知道 client 已经收到了一些数据，所以我收下这些数据，并接着到 master 清单，并将数据送给其它已连接的每个 clients。

我的朋友们，以上对万能 **select()** 函数的概述，这真是不简单的事情。

另外，这里有个福利：一个名为 **poll** 的函数，它的行为与 **select()** 很像，但是在管理 file descriptor sets 时用不一样的系统，你可以看看 [poll](http://beej-cn.netdpi.net/09-man-manual/9-17-poll)。