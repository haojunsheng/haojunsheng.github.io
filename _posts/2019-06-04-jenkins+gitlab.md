---
layout: post
title: "2019-06-04-jenkins+gitlab"
date: 2019-06-04 
description: "2019-06-04-jenkins+gitlab"
categories: fabric

tag: fabric
---


# 1.相关概念

互联网软件的开发和发布，已经形成了一套标准流程，假如把开发工作流程分为以下几个阶段：编码 --> 构建 --> 集成 --> 测试 --> 交付 --> 部署

![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145631424-1988978732.png)

**持续集成（CI）**上面整个流程中最重要的组成部分就是持续集成（Continuous integration，简称CI）。持续集成指的是，频繁地（一天多次）将代码集成到主干。将软件个人研发的部分向软件整体部分交付，频繁进行集成以便更快地发现其中的错误。它的好处主要有两个：

1. 快速发现错误。每完成一点更新，就集成到主干，可以快速发现错误，定位错误也比较容易； 
2. 防止分支大幅偏离主干。如果不是经常集成，主干又在不断更新，会导致以后集成的难度变大，甚至难以集成。

**持续交付**
持续交付（Continuous delivery）指的是，频繁地将软件的新版本，交付给质量团队或者用户，以供评审。如果评审通过，代码就进入生产阶段。

持续交付在持续集成的基础上，将集成后的代码部署到更贴近真实运行环境的「类生产环境」(production-like environments)中。持续交付优先于整个产品生命周期的软件部署，建立在高水平自动化持续集成之上。

**持续部署（CD）**
持续部署（continuous deployment）是持续交付的下一步，指的是代码通过评审以后，自动部署到生产环境。持续部署的目标是，代码在任何时刻都是可部署的，可以进入生产阶段。持续部署的前提是能自动化完成测试、构建、部署等步骤

![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604122804931-332079019.png)

1.客户端发起代码push到gitlab上
2.gitlab配置了webhook的东西，它可以出发jenkins的构建
jenkins做的事情就比较多
3.1 构建代码
3.2 静态分析
3.3 单元测试
3.4 build镜像
3.5 推送push镜像仓库
3.6 调用k8s的apik8s拉取镜像仓库的进行部署。

# 2. Jenkins介绍及相关软件的安装

Jenkins是一个开源的、可扩展的持续集成、交付、部署（软件/代码的编译、打包、部署）的基于web界面的平台。允许持续集成和持续交付项目，无论用的是什么平台，可以处理任何类型的构建或持续集成。

开源的java语言开发持续集成工具，支持CI，CD；

易于安装部署配置：可通过yum安装,或下载war包以及通过docker容器等快速实现安装部署，可方便web界面配置管理；

消息通知及测试报告：集成RSS/E-mail通过RSS发布构建结果或当构建完成时通过e-mail通知，生成JUnit/TestNG测试报告；

分布式构建：支持Jenkins能够让多台计算机一起构建/测试；

文件识别:Jenkins能够跟踪哪次构建生成哪些jar，哪次构建使用哪个版本的jar等； 

丰富的插件支持:支持扩展插件，你可以开发适合自己团队使用的工具，如git，svn，maven，docker等。

## 2.1Jenkins的安装

一定要看官网[官网](https://jenkins.io/doc/pipeline/tour/getting-started/)

Jenkis依赖Java，但是需要注意的是java9是不可以使用的，所以我们需要安装Java8，在安装Java8的时候，又出现一个坑，Oracle需要登录才可以下载sdk，如果不想登录的话，可以使用`sudo apt-get install oracle-java8-installer`来安装。

下面开始安装Jenkins。

1. 添加key 
   `wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -`
2. 修改/etc/apt/sources.list:
   添加下面的源：

`deb https://pkg.jenkins.io/debian-stable binary/`

3 apt的方式安装
`sudo apt-get update

sudo apt-get install jenkins`

如果我们需要修改端口的话，以Ubuntu 18.04为例：`vim /etc/default/jenkins`，在这个地方把8080改成相应的端口即可。然后注意把Jenkins重新启动，`/etc/init.d/jenkins restart`。然后我们需要获取密钥，在Jenkins初始化的时候会需要，`cat /var/lib/jenkins/secrets/initialAdminPassword`，我们把密钥复制。在浏览器输入http://ip:port即可。接下来是傻瓜式操作。在我配置完成之后，遇到了一个坑爹的问题，浏览器变成了白屏，最后的解决方案是重新启动Jenkins服务，重启解决一切问题啊。

4. jar包的方式安装
   或者可以直接下在[jar包](http://mirrors.jenkins.io/war-stable/latest/jenkins.war)，
   我们有多种方法启动，我们选择使用jar包的方法，

java -jar jenkins.war --httpPort=31000

然后操作方法同上。

5. docker jenkins安装

我使用的这一中。

[docker官网](https://hub.docker.com/_/jenkins/)

使用dockers拉去镜像，`docker pull jenkins` ，经过等待后，我们使用docker images查看下载的镜像。

也可以使用docker来启动：

`docker run -p 8080:8080 -p 50000:50000 -d -v /your/home:/var/jenkins_home jenkins`

我们来看看各个参数的含义：

-d: 后台运行容器，并返回容器ID;

-p 8080:8080 将镜像的8080端口映射到服务器的8080端口;    50000:50000 将镜像的50000端口映射到服务器的50000端口;

-v jenkins:/your/home:/var/jenkins_home,jenkins工作目录和宿主机目录进行映射，必须保证当前用户具有your/home访问权限。

除此之外，我们还可能遇到这样的权限问题，
![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145723670-947073822.png)

原因是Jenkins镜像内部使用的用户是jenkons，但是我启动容器时的账号是root，导致没有权限操作内部目录，我们可以稍微改一下上面的命令：
`docker run -p 8080:8080 -p 50000:50000 -d -v /your/home:/var/jenkins_home -u 0 jenkins`
这样就可以成功启动了，该命令的作用是覆盖掉用户jenkons微root。

也可以使用
`docker run --name myjenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home jenkins` 。

这个和前面不太一样，生成的密钥在docker容器中，使用docker ps -a，查看当前运行的容器，在使用`docker exec -it 76b66ca806f7 /bin/bash` ，记得替换为自己的容器id。

在容器中执行cat /var/jenkins_home/secrets/initialAdminPassword,获得相应密钥即可进行初始化，同上。

其实Jenkins的插件的安装还是有很多的坑的，主要的原因还是在于网络的原因，我们可以把把源替换为清华的源。
在系统管理---》插件管理-》高级 里面进行设置。
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

此外，我还遇到一个坑爹的问题，服务器的访问特别的缓慢，配置文件根本打不开，我一度怀疑是网络的问题，切换微我的手机流量，问题依然无法解决，我甚至把改容器给删除，镜像重新下载，还是无法解决问题，直到最后我发现容器的状态是unhealthy，我使用docker logs contained --tail 100,  查看了docker的日志。这样就很明确了，硬盘空间不够啦。![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145802066-809764824.png)
下面，我使用df -xh命令查看当前硬盘的使用率，很明显，就是这个问题。
![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145827896-2102810417.png)
我的解决思路是把docker的镜像和容器给迁移到其他富余的空间，如下：
1.停止docker服务。`systemctl stop docker`
2.创建一个目录用于保存docker的镜像和容器，mkdir -p /opt/docker/lib
3.迁移/var/lib/docker到上面的目录中，rsync -avz /var/lib/docker  /opt/docker/lib
4.配置docker的配置文件，Ubuntu下的docker配置文件在，/lib/systemd/system/docker.service，修改
ExecStart=/usr/bin/dockerd --graph=/opt/docker/lib/docker
5.重写加载docker

```
systemctl daemon-reload
 
systemctl restart docker
 
systemctl enable docker
```

6. 查看是否成功
   docker info

![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145851470-801075982.png)

deal。。。。

docker images查看镜像，docker ps -a 查看容器。

7. 收尾
   如果没有任何问题，就可以把/var/lib/docker删除即可。



## 2.2 docker gitlab的安装

写在前面：在安装之前，我们需要弄明白一件事情，搞明白gitlab和GitHub的区别，多余的废话不说，主要体现在github相当于我们需要把代码部署到别人的服务器上，而我们可以使用gitlab在我们自己的服务器上搭建一个git环境，代码也可以放在我们自己的服务器上，这样我们即享受了git的方便，也保护了代码的安全。

先参考官网：[gitlab docker官网](https://docs.gitlab.com/omnibus/docker/README.html)

使用 `docker pull gitlab/gitlab-ce` 来安装。

接下来使用

```
sudo docker run --detach \ 
--hostname gitlab.example.com \ 
--publish 443:443 --publish 80:80 --publish 22:22 \ 
--name gitlab \ 
--restart always \ 
--volume /srv/gitlab/config:/etc/gitlab \ 
--volume /srv/gitlab/logs:/var/log/gitlab \ 
--volume /srv/gitlab/data:/var/opt/gitlab \ 
gitlab/gitlab-ce:latest
```

不幸的是，服务器报了下面的错误，大意是说，服务器端口22被占用了。
![](https://img2018.cnblogs.com/blog/1358741/201905/1358741-20190530231940887-1984738474.png)
使用lsof -i:22查看：
![](https://img2018.cnblogs.com/blog/1358741/201905/1358741-20190530232710034-856583925.png)
知道了问题，解决起来也不难，我们把端口映射修改一下即可，即

```
sudo docker run --detach \ 
--hostname gitlab.example.com \ 
--publish 443:443 --publish 80:80 --publish 2222:22 \ 
--name gitlab \ 
--restart always \ 
--volume /srv/gitlab/config:/etc/gitlab \ 
--volume /srv/gitlab/logs:/var/log/gitlab \ 
--volume /srv/gitlab/data:/var/opt/gitlab \ 
gitlab/gitlab-ce:latest
```

下面这个表是gitlab的映射关系
![](https://img2018.cnblogs.com/blog/1358741/201905/1358741-20190530233231711-1734548157.png)

我们可以修改gitlab的配置

docker exec -it gitlab /bin/bash

然后修改/etc/gitlab/gitlab.rb即可，

```
sudo docker run --detach \ 
--hostname gitlab.example.com \ 
--env GITLAB_OMNIBUS_CONFIG="external_url 'http://my.domain.com/'; gitlab_rails['lfs_enabled'] = true;" \ 
--publish 443:443 --publish 80:80 --publish 2222:22 \ 
--name gitlab \ --restart always \ 
--volume /srv/gitlab/config:/etc/gitlab \ 
--volume /srv/gitlab/logs:/var/log/gitlab \ 
--volume /srv/gitlab/data:/var/opt/gitlab \ 
gitlab/gitlab-ce:latest
```

最后
sudo docker restart gitlab

接下来我们可以在浏览器打开gitlab,输入http://ip:port,这里port因为是80，所以可以省略。然后是让设置新的密码。再然后就要登录，登录的时候千万要注意，**这个地方不是输入你在gitlab官方上的用户名和密码**，用户名应该是root，密码是刚才设置的。

**小贴士**：如果你不幸的忘记了密码，自然是有办法补救的。
[重置密码](https://docs.gitlab.com/ce/security/reset_root_password.html)  ，我们需要进入到gitlab容器中，注意必须是root账户，然后
`gitlab-rails console production` ，注意这个过程需要花费时间，耐心等待即可，
![](https://img2018.cnblogs.com/blog/1358741/201905/1358741-20190531103642854-1823974143.png)

完成之后，我们可以使用两种方式来找到用户名或者邮箱，`user = User.where(id: 1).first`  或者是
`user = User.find_by(email: 'admin@local.host')` 。最后我们修改密码即可，
`user.password = 'secret_pass' 
user.password_confirmation = 'secret_pass'`

不要忘记保存哦。
`user.save!`
退出控制台，重新登录即可。

好的，我们回到前面，登录到http://ip:port之后，我们创建组，创建用户，把用户添加到组里面，创建项目，这些比较简单，不在贴出来了。

在项目创建好之后，我遇到了这么一个问题，说是我没有配置ssh，所以不能通过ssh的方式来获取代码，这个很简单，配置下ssh就可以了。
![](https://img2018.cnblogs.com/blog/1358741/201905/1358741-20190531105811866-1062421896.png)

此外，我们还可以配置我们服务器的IP地址。操作如下，打开vim /etc/gitlab/gitlab.rb文件，将external_url = 'http://git.example.com'修改成自己的HostName。
接下来我们可以配置邮件服务器，需要安装邮件服务，apt-get install postfix，apt-get install mailutils，安装完成后可以进行测试
echo "Test mail from postfix" | mail -s "Test Postfix" @qq.com

到这里，我们就完成了公司级别的gitlab服务器的搭建。

# 3. jenkins实战

## 3.1 流水线

Jenkinsfile 。

![](https://img2018.cnblogs.com/blog/1358741/201906/1358741-20190604145915729-153312059.png)

声明式流水线：

```
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any //在任何可用的代理上，执行流水线或它的任何阶段。
    stages {
        stage('Build') { 
            steps {
                // 
            }
        }
        stage('Test') { 
            steps {
                // 
            }
        }
        stage('Deploy') { 
            steps {
                // 
            }
        }
    }
}
```

脚本化流水线：

```
enkinsfile (Scripted Pipeline)
node {  
    stage('Build') { 
        // 
    }
    stage('Test') { 
        // 
    }
    stage('Deploy') { 
        // 
    }
}
```