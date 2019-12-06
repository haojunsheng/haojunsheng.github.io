---
layout: post
title: "Linker & Loader"
date: 2019-12-05
description: "2019-12-05-Linker & Loader"
categories: 编译原理

tag: 编译原理

---

[toc]

# 1. 前言

之前在学习java的JVM的时候，总是傻傻的分不清堆，栈，数据区，代码区什么的，查了很多的资料，都是很零碎的，学的也很乱，其实现在才发现，这些都是编译原理里面的。

下面的内容我主要参考的是《程序员的自我修养，链接，装载与库》和《Links and Loaders》。

我没有按照实际的顺序，按照的书的顺序，方便以后的查找，只是摘录了现阶段比较重要的东西，像是语义分析之类的，直接省略了。动态链接的内容也是比较少，以后用到的时候，在来补充吧。

# 2.静态链接 

## 2.3目标文件 

ELF，executable linkable format。动态链接库（.so）和静态链接库（.a）都是按照可执行文件格式存储。 

目标文件.o。 

目标文件按照段的方式来存储。 

### 2.3.4 ELF文件结构描述 

文件头，段表，重定位表，字符串表（段名，变量名），符号表。 

**字符串表和符号表的区别：** 

我的理解字符串表存放的是，字符串的值，如String s1="hello world",那么s1存放在符号表中，hello world存放在字符串表中，s1的值是hello world的地址。 

确实我的理解是对的。 

准备程序，simpleSecticon.c 

```c
int printf(const char* format,...); 

int global_init_var = 84; 

int global_uninit_var; 

void func1(int i){ 

printf("%d\n", i); 

} 

int main(void) 

{ 

static int staic_var = 85; 

static int staic_var2; 

int a = 1; 

int b; 

func1(staic_var + staic_var2 + a + b); 

return a; 

} 
```

只编译不连接：gcc -c simpleSecticon.c 

使用objdump -h simpleSecticon.o来打印基本信息： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205112927.png)

将所有段的内容以十六进制的方式打印，并且指令反汇编 

objdump -s -d simpleSecticon.o 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113009.png)

使用readelf -h simpleSecticon.o来查看头部基本信息 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113026.png)



```c
/* The ELF file header. This appears at the start of every ELF file. */ 

\#define EI_NIDENT (16) 

typedef struct 

{ 

unsigned char e_ident[EI_NIDENT]; /* Magic number and other info */ 

Elf32_Half e_type; /* Object file type */ 

Elf32_Half e_machine; /* Architecture */ 

Elf32_Word e_version; /* Object file version */ 

Elf32_Addr e_entry; /* Entry point virtual address */ 

Elf32_Off e_phoff; /* Program header table file offset */ 

Elf32_Off e_shoff; /* Section header table file offset */ 

Elf32_Word e_flags; /* Processor-specific flags */ 

Elf32_Half e_ehsize; /* ELF header size in bytes */ 

Elf32_Half e_phentsize; /* Program header table entry size */ 

Elf32_Half e_phnum; /* Program header table entry count */ 

Elf32_Half e_shentsize; /* Section header table entry size */ 

Elf32_Half e_shnum; /* Section header table entry count */ 

Elf32_Half e_shstrndx; /* Section header string table index */ 

} Elf32_Ehdr; 
```



使用readelf -S simpleSecticon.o来查看详细的段表结构，段表的结构是Elf32_Shdr,定义在/usr/include/elf.h中。 

```c
typedef struct 

{ 

Elf32_Word sh_name; /* Section name (string tbl index) */ 

Elf32_Word sh_type; /* Section type */ 

Elf32_Word sh_flags; /* Section flags */ 

Elf32_Addr sh_addr; /* Section virtual addr at execution */ 

Elf32_Off sh_offset; /* Section file offset */ 

Elf32_Word sh_size; /* Section size in bytes */ 

Elf32_Word sh_link; /* Link to another section */ 

Elf32_Word sh_info; /* Additional section information */ 

Elf32_Word sh_addralign; /* Section alignment */ 

Elf32_Word sh_entsize; /* Entry size if section holds table */ 

} Elf32_Shdr; 
```

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113136.png)

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113154.png) 

### 2.3.5 链接的接口-符号 

ELF符号表结构，特殊符号。 

函数名和变量名叫符号名（Symbol），符号的值是地址。 

使用nm simpleSection.o来查看符号和符号值之间的关系, 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113237.png) 

也可以使用readelf -s simpleSection.o来查看 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113249.png) 

``` c
/* Symbol table entry. */ 

typedef struct 

{ 

Elf32_Word st_name; /* Symbol name (string tbl index) */ 

Elf32_Addr st_value; /* Symbol value */ 

Elf32_Word st_size; /* Symbol size */ 

unsigned char st_info; /* Symbol type and binding */ 

unsigned char st_other; /* Symbol visibility */ 

Elf32_Section st_shndx; /* Section index */ 

} Elf32_Sym; 
```

### 2.3.6 调试 

在目标代码里，保存了源代码和目标代码之间的映射。 

## 2.4 静态链接 

空间和地址分配，符号解析与重定位，common块，静态库链接，链接过程控制，BFD库 

### 2.4.1 空间和地址分配 

**分配地址和空间有2层含义：第一个指的是可执行文件中的空间，第二个执行的是装载后在虚拟地址中的空间。** 

\- 按序叠加： 

\- 优点：简单 

\- 缺点：浪费空间 

\- 相似段合并： 

链接分为2步，第一步是空间与地址分配，第二步是符号解析与**重定位**。 

使用gcc a.o b.o -e main可以进行链接，（注，书上是ld，但是我用ld不可以） 

接下来我们使用objdump来查看链接前后的地址分配情况： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113429.png)

其中，vma（virtual memory address）表示虚拟地址，lma（load memory address）表示加载地址。 

总结，先确定各个段的地址，在确定符号的地址，且符号的地址是在段内是相对固定的。 

### 2.4.2 符号地址解析与重定位 

我们先来看重定位，使用objdump -d a.o进行反汇编来看下效果： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113455.png)

我们可以看到调用的地址并不是真正的地址，而是00。 

然后，我们在来用objdump -d a.out来看下重定位的效果： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113518.png)

我们可以看到，已经是真正的地址了。 

那么问题来了，链接器怎么知道如何调整指令呢？这就引入了下一个话题，重定位表（Relocation Table）。重定位表的规则是：如果.data段有需要重定位的，那么还有一个段叫做.rel.data。我们可以使用objdump -r a.o来进行查看： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113533.png) 

```c
/* Relocation table entry without addend (in section of type SHT_REL). */ 

typedef struct 

{ 

Elf32_Addr r_offset; /* Address */ 

Elf32_Word r_info; /* Relocation type and symbol index */ 

} Elf32_Rel; 
```



事情还没有完，在重定位的过程中，往往还伴随着符号解析，所以在符号表里面必须进行定义。我们可以使用readelf -s a.o来查看符号表。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113612.png) 

### 2.4.5 静态库链接 

我们使用ar -t /usr/lib/x86_64-linux-gnu/libc.a来查看c语言所提供的库包含哪些静态库： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113632.png) 

我们使用objdump -t /usr/lib/x86_64-linux-gnu/libc.a | grep printf.o来查看目标print.o文件。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113650.png) 

我们发现一个仅仅打印hello world的程序需要和很多其他的库进行链接。 

我们可以使用 gcc -static --verbose -fno-builtin hello.c来把编译链接的过程的中间步骤打印出来。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113704.png) 

总结下，三个关键步骤，第一个调用ccl程序（gcc的c语言编译器）把hello.c变成/tmp/ccUhtGSB.s。 

第二步调用as(GNU的编译器)把/tmp/ccUhtGSB.s变成/tmp/ccQZRPL5o，其实就是hello.o； 

最后一步是用collect2来完成链接。 

### 2.4.6 链接过程控制 

我们来尝试自己实现一个hello world，不同的是我们不在使用main，printf这样的库函数。 

```c
// TinyHelloWorld.c 

char *str = "Hello World!\n"; 

// use Linux WRITE system call 

void print(){ 

asm("mov $13,%%edx \n\t" 

"mov $0,%%ecx \n\t" 

"mov $0,%%ebx \n\t" 

"mov $4,%%eax \n\t" 

"int $0x80 \n\t" 

::"r"(str):"edx","ecx","ebx"); 

} 

// use Linux EXIT system call 

void exit(){ 

asm("mov $42,%%ebx \n\t" 

"mov $1,%%eax \n\t" 

"int $0x80 \n\t" 

::"r"(str):"edx","ecx","ebx"); 

} 

void nomain(){ 

print(); 

exit(); 

} 
```

gcc -c -fno-builtin TinyHelloWorld.c 

ld -static -e nomain -o TinyHelloWorld TinyHelloWorld.o 

# 3.装载与动态链接 

## 6 可执行文件的装载与进程 

研究可执行文件装载的本质，什么是进程的虚拟地址空间？为什么进程要有自己的虚拟地址空间？从历史的角度来看装载的几种方式，包括覆盖装载，页映射。接着会研究进程虚拟地址空间的分布情况，比如代码段，数据段，BSS段，堆，栈在进程的地址空间是怎么分布的，他们的位置和长度如何决定？ 

### 6.1 进程虚拟地址空间 

32位cpu和64位cpu的区别：32位指的是寻址空间，即4G，64位的寻址空间很大，2^64。不是实际内存的大小。 

### 6.2 装载的方式 

覆盖装入（Overlay）和页映射（Paging），前者已经被抛弃。 

### 6.3 从操作系统角度看可执行文件的装载 

\- 创建一个独立的虚拟地址空间，映射了虚拟内存和物理内存，实际上是创建映射函数所需要的数据结构。 

\- 读取可执行文件头，并且建立虚拟空间与可执行文件的映射关系。 

\- 将CPU的指令寄存器设置成可执行文件的入口地址，启动执行。 

### 6.4 进程虚存空间分布 

#### 6.4.1 ELF文件链接视图和执行视图 

为了减少段的数量多导致的空间的浪费，我们按照段的权限把段进行合并。我们引入了一个新的概念，Section表示链接视图，Segment表示执行视图，我们来看一下具体的例子： 

```c
SectionMapping.c 

#include "stdlib.h" 

int main(){ 

while(1){ 

sleep(10); 

} 

return 0; 

} 
```

先进行静态链接：gcc -static SectionMapping.c -o SectionMapping.elf 

然后我们按Section来看，总共32个段：readelf -S SectionMapping.elf 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205113950.png) 

然后我们按Segment来看，总共5个,readelf -l SectionMapping.elf 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114003.png) 

程序头表。 

```c
/* Program segment header. */ 

typedef struct 

{ 

Elf32_Word p_type; /* Segment type */ 

Elf32_Off p_offset; /* Segment file offset */ 

Elf32_Addr p_vaddr; /* Segment virtual address */ 

Elf32_Addr p_paddr; /* Segment physical address */ 

Elf32_Word p_filesz; /* Segment size in file */ 

Elf32_Word p_memsz; /* Segment size in memory */ 

Elf32_Word p_flags; /* Segment flags */ 

Elf32_Word p_align; /* Segment alignment */ 

} Elf32_Phdr; 
```

#### 6.4.2 堆和栈 

VMA的用途：映射可执行文件中的Segment，对进程的地址空间进行管理。 

我们使用./SectionMapping.elf & 

cat /proc/16148/maps 来查看进程的虚拟空间分布。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114108.png)

第一列表示VMA的地址范围，第二列表示权限（r读，w写，x执行，p私有，s共享），第三列表示偏移，第四列是主次设备号，第五列节点号，第六列文件的路径。 

一个进程可以分为如下几种VMA区域： 

\- 代码VMA： 

\- 数据VMA； 

\- 堆VMA；无映像文件，可向上扩展 

\- 栈VMA：无映像文件，可向下扩展 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114125.png)

#### 6.4.3 堆的最大申请数量 

### 6.5 Linux内核装载ELF过程简介 

我们从fork和execlp来实现minibash： 

```c
// minibash.c 

#include <stdio.h> 

#include <sys/types.h> 

#include <unistd.h> 

int main(){ 

char buf[1024] = {0}; 

pid_t pid; 

while(1){ 

printf("minibash$"); 

scanf("%s",buf); 

pid = fork(); 

if(pid == 0){ 

if(execlp(buf,0) < 0){ 

printf("exec error\n"); 

} 

}else if(pid > 0){ 

int status; 

waitpid(pid,&status,0); 

}else{ 

printf("fork error %d\n", pid); 

} 

} 

return 0; 

} 
```

do_execve()(处理128字节的文件头部)-->>search_binary_handle()-->load_elf_binary()(装载可执行脚本)，在然后就是返回do_execve，在返回sys_execve，然后在返回到用户态。 

我们来详细看下[load_elf_binary](https://elixir.bootlin.com/linux/v4.4/source/fs/binfmt_elf.c#L665)的实现： 

\- 检查ELF可执行文件格式的有效性，比如魔数； 

\- 寻找动态链接中的"interp"段，设置动态链接路径； 

\- 根据ELF可执行文件的程序头表的描述，对ELF文件进行映射，比如代码，数据，只读数据； 

\- 初始化ELF进程环境 

\- 将系统调用的返回地址修改为ELF可执行文件的入口点。 

总结：程序使用内存空间的问题，程序如何被操作系统加载到内存，页映射的好处，从操作系统的角度观察了进程如何被建立，程序开始运行时发生错误该如何处理。 

还介绍了进程虚拟地址空间的分布，操作系统如何为程序的代码，数据，堆，栈在进程地址空间中的分配，以及如何分布的，然后我们谁让你如学习了Linux是如何装载并且运行ELF的。 

## 7. 动态链接 

### 7.1 为什么要动态链接 

浪费空间，模块更新困难引入了动态链接，节省了内存，减少了物理页面的换入换出，增加了CPU的命中率，易于升级。 

但是动态链接也不是万能的，也有其他的缺点，新旧版本无法兼容是最大的问题。 

动态链接的基本实现：程序被分为主要模块和动态链接库。当程序被装载的时候，动态链接器会把所有的动态链接库装载到程序的进程空间，真正的链接工作是由动态链接器完成的，也就是说，被延后了。但是性能会损失5%左右，还是十分划算的。 

### 7.2 简单的动态链接例子 

```c
//Program1.c 

#include "Lib.h" 

int main(){ 

foobar(1); 

return 0; 

} 

//Program2.c 

#include "Lib.h" 

int main(){ 

foobar(2); 

return 0; 

} 

//Lib.c 

#include "stdio.h" 

void foobar(int i){ 

printf("Printing from Lib.so %d\n",i); 

} 

//Lib.h 

#ifndef LIB_H 

#define LIB_H 

void foobar(int i); 

#endif 
```

使用方法： 

gcc -fPIC -shared -o Lib.so Lib.c 

gcc -o Program1 Program1.c ./Lib.so 

gcc -o Program1 Program2.c ./Lib.so 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114314.png)

从这张图片中，我们可以看到，貌似Lib.so也参与了链接过程，这是为什么呢？原来，在静态链接中，目标文件直接参与了链接，地址进行了重定位。在动态链接中，只是进行了标记，实质上还是在运行中进行链接的。 

下面我们来看下动态链接程序在运行时的地址空间分布： 

对于动态链接来讲，分为可执行文件和动态共享库，首先我们需要在Lib.c中加入sleep函数，即： 

```c
//Lib.c 

#include "stdio.h" 

void foobar(int i){ 

printf("Printing from Lib.so %d\n",i); 

sleep(-1); 
} 
```

然后重新编译,看进程的虚拟地址空间分布： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114347.png) 

可以看到，二者被操作系统用同样的方法映射到进程中。 

我们再次使用readelf -l Lib.so来查看装载属性： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114408.png) 

### 7.3 地址无关代码 

共享对象在装载的时候，我们如何确定它在进程虚拟地址空间中的位置？我们第一个面临的问题就是共享对象地址冲突的问题。 

为了解决地址冲突的问题，我们要让共享对象在编译时不能假设自己在进程虚拟地址空间中的位置。（与之对应的是，可执行文件在编译的时候基本就可以知道自己在虚拟地址空间中的位置） 

于是我们引入了装载时重定位：即在装载时对所有的绝对地址的引用不做重定位，在装载的时候在做。假设foobar相对于代码段的位置是0x100,当该模块的地址装载在0x1000,那么foobar的地址是0x1100。 

但是并没有解决所有的问题，无法在多个进程间共享，浪费空间。在来看下，我们的目的是**希望程序模块中共享的指令在装载时不需要因为装载地址的改变为改变**。所以我们的思路很简单，把指令中需要修改的部分抽离出来，和数据放在一块，这样，指令部分就可以保持不变，数据部分在每个进程中持有一个副本。这种方案就是**地址无关代码**（PIC，Position-independent Code）。 

在此之前，我们需要分析模块中各种类型地址的引用方式： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114428.png) 

函数内部调用、跳转： 

# 4 库与运行库 

## 10 内存 

### 10.1 程序的内存布局 

一般情况下，我们的内存可以分为： 

\* 内核空间 

\* 用户空间 

\* 栈：用于维护函数调用的上下文； 

\* 堆：用来动态分配的区域； 

\* 可执行文件映像：存储着可执行文件在内存里的映像，装载时将可执行文件的内存读取到这里； 

\* 保留区：不是单一的，比如NULL是受保护的。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114448.png) 

### 10.2 栈 

我们为什么要用栈？--主要是为了处理函数调用。 

栈里面的2个重要概念，esp（栈指针）和ebp（帧指针），堆栈一般包含下面的内容： 

\- 函数的返回地址和参数； 

\- 临时变量：函数的非静态局部变量； 

\- 保存的上下文：在函数调用前后需要保持不变的寄存器。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114504.png) 

稍微解释下这个图：ebp固定不变，指向调用该函数前ebp的值，用于函数返回时使用。ebp-4是函数的返回地址，ebp-8，ebp-12是参数等。 

下面我们来看下函数调用究竟是怎么实现的： 

1. 把所有或者一部分参数压入栈中； 

2. 把当前指令的下一条指令的地址压入栈中； 

3. 调到函数体执行； 
   1. push ebp; ebp压入栈中（俗称old ebp） 
   2. mov ebp,esp;ebp=esp(ebp指向栈顶，也即old ebp) 
   3. sub esp,XXX;在栈上分配空间 
   4. push XXX:保存寄存器的值，因为有些函数要求寄存器在调用前后不能发生改变 
   5. pop XXX:恢复保存的寄存器 
   6. mov esp,ebp：恢复ESP同时回收局部变量空间 
   7. pop ebp：恢复ebp 
   8. ret：取出返回地址 

下面我们来举个例子： 

int foo(){ 

return 123; 

} 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114555.png) 

不知道大家发现问题没，在上面的过程中，有些我们必须进行约定，才能正常的处理函数之间的调用，标准如下所示： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114607.png) 

我们再来举个例子： 

```c
void f(int x,int y){ 

return; 

} 

int main(){ 

f(1,3); 

return 0; 

} 
```

函数的实际执行流程如下所示： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114635.png) 

到现在，我们还有一个非常棘手的问题，就是函数的返回值我们需要怎么进行处理： 

我们分为以下几类情况： 

\* 返回值小于4个字节：把值存储在eax寄存器中，然后从eax中读取； 

\* 大于4小于8：eax+edx; 

\* 大于8字节：这才是复杂的，可以明确的是肯定在寄存器中存地址； 

我们通过一个实例来研究： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114647.png) 

可以明确的是128字节是不可能在eax里存下的，所以肯定是地址，步骤如下： 

1. main函数在栈上额外开辟一个空间，成为temp 

2. 将temp的地址作为隐藏参数传递给return_test函数 

3. return_test把数据拷贝给temp，并把temp的地址放在eax寄存器中 

4. return_test返回后，main函数将eax执行的temp对象拷贝给n 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114704.png) 

我们可以看到，2次拷贝还是十分浪费空间的，我们应该尽量减少返回大对象。 

### 10.3 堆与内存管理 

**为什么我们有了栈，还要有堆呢？** 

我们知道变量的声明周期会随着函数的结束而结束，如果我们想要让变量的声明周期增长，那么我们必须使用全局变量，但是全局变量的缺点也是十分的明显的，首先太多的全局变量无法维护，然后全局变量只可以在编译前进行分配内存，无法在运行时分配内存。所以我们引入了堆。 

在c语言中，我们是通过malloc来实现的，我们的思路有2个，一是由操作系统来做，但是缺点也很明显，会影响性能，而是由程序来实现。做法是程序向内核申请一块内存，然后由程序把这段内存分配下去。简而言之，就是批量申请，逐个分配。 

linux系统的进程堆管理，主要依靠两个函数：brk和mmap。 

```c
int brk(void* end_data_segment); 

void *mmap(void *start, 

size_t length, 

int prot, 

int flags, 

int fd, 

off_t offset); 
```

我们还有一个复杂的问题要处理，就是堆分配算法。 

**我们究竟要如何管理一大块连续的内存空间，按需分配，释放空间。** 

常见的有以下几种方法： 

空闲链表：把空闲的块串成一个链表，需要的时候，拆分下来，释放的时候，合并到链表中。

位图：![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114756.png)对象池： 

## 12 系统调用 

Linux系统差不多有300多个系统调用。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114811.png)

下面我们来看下系统调用的原理。用户模式和内核模式，由用户模式进入进入内核模式，有2中方法，一是轮询，2是信号。 

中断有2个属性，1是中断号，2是中断处理程序，在内核中，有一个数组被称为中断向量表，保存了所有的中断类型。 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114832.png) 

我们用中断号+系统调用号来表示一个具体的中断。一般int指令表示进入中断，0x80表示系统调用。 

下面我们来看下基于int的Linux经典系统调用： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114900.png) 

第一步是触发中断，第二步是切换堆栈，具体来讲，我们需要从用户太的堆栈切换到内核态的堆栈，需要如下步骤： 

1. 保存当前的ESP和SS的值； 

2. 将ESP和SS的值设置为内核栈的相应值； 
   1. 找到当前进程的内核栈（每一个进程都有自己的内核栈） 
   2. 在内核中依次压入用户的寄存器SS,ESP,EFLAGS,CS,EIP 
   3. 恢复原来的ESP和SS的值（iret） 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114922.png) 

第三步是中断处理程序， 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114933.png) 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114948.png) 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205114958.png) 

# 附录 

ELF常见段： 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205115015.png) 

![](https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191205115029.png) 