---
layout: post
title: "k8s的学习之路"
date: 2019-12-15
description: "2019-12-15-k8s的学习之路"
categories: docker
tag: docker
---

<!--ts-->

<!--te-->

# 前言

Kubernetes，也即k8s,是 Google 开源的容器集群管理系统，是 Google 多年大规模容器管理技术 Borg 的开源版本，也是 CNCF 最重要的项目之一，主要功能包括: 

- 基于容器的应用部署、维护和滚动升级; 
- 负载均衡和服务发现; 
- 跨机器和跨地区的集群调度; 
- 自动伸缩; 
- 无状态服务和有状态服务; 
- 广泛的 Volume 支持;
-  插件机制保证扩展性。 

# 1 官方文档

我们最需要看的就是官方文档。

## 1.1 Overview

Kubernetes 是一个跨主机集群的 [开源的容器调度平台，它可以自动化应用容器的部署、扩展和操作](http://www.slideshare.net/BrianGrant11/wso2con-us-2015-kubernetes-a-platform-for-automating-deployment-scaling-and-operations) , 提供以容器为中心的基础架构。

### 1.1.1 什么是k8s?

#### 回顾

![Deployment evolution](https://d33wubrfki0l68.cloudfront.net/26a177ede4d7b032362289c6fccd448fc4a91174/eb693/images/docs/container_evolution.svg)

- 传统的部署：应用运行在物理机上，对资源的使用没有边界，不同的应用的解决方案只能是使用不同的物理机，但是价格是十分的昂贵的。
- 虚拟化部署：为了解决上面的问题，我们引入了虚拟机，一台物理机上可以运行多个虚拟机。虚拟机为应用提供了隔离技术。
- 容器化部署：和虚拟机是相似的，但是可以提供很方便的隔离环境，在底层架构就解耦了。容器主要提供了下面的优势：
  - 敏捷创建，敏捷部署
  - 持续开发，集成，部署
  - 开发运营分离
  - 可监控应用程序的运行状况
  - 开发，测试，生产环境一致性
  - 操作系统和云服务的可移植性
  - 更加关注应用本身
  - 低耦合，分布式，弹性和微服务
  - 资源隔离
  - 资源利用

#### k8s的优点

k8s为我们提供了在分布式系统中运行容器的方案，它负责应用程序的扩展和故障转移，提供部署模式等。k8s为我们提供了下面的优势：

- 服务发现和负载均衡，通过域名和IP地址来实现的。
- 存储编排（**Storage orchestration**）：可以把本地和云挂载在一块。
- 自动部署和回滚：
- **Automatic bin packing**：k8s可以让集群按照我们分配的CPU和内存来运行
- 自我修复
- 安全配置管理

#### k8s的局限

Kubernetes不是一个传统的，包罗万象的PaaS（平台即服务）系统。由于Kubernetes在容器级别而不是硬件级别运行，因此它提供了PaaS产品共有的一些普遍适用的功能，例如部署，扩展，负载平衡，日志记录和监视。但并且这些默认解决方案是可选的和可插入的。Kubernetes提供了构建开发人员平台的基础，但是在重要的地方保留了用户的选择和灵活性。

- 不限制支持的应用程序类型。Kubernetes旨在支持极其多种多样的工作负载，包括无状态，有状态和数据处理工作负载。如果应用程序可以在容器中运行，那么它应该可以在Kubernetes上很好地运行。
- 不部署源代码，不支持构建应用。
- 不提供应用程序级服务，例如中间件（例如，消息总线），数据处理框架（例如，Spark），数据库（例如，MySQL），高速缓存或群集存储系统（例如，Ceph）作为内置服务。这样的组件可以在Kubernetes上运行，和/或可以由Kubernetes上运行的应用程序通过可移植机制（例如Open Service Broker）进行访问。
- 不提供日志记录，监视或警报解决方案。
- 不提供配置系统
- 不提供也不采用任何全面的机器配置，维护，管理或自我修复系统。

### 1.1.2 k8s组件

集群是机器（节点）的集合，一个集群至少一个work node,一个master node。work node管理应用程序组件的pod。master 管理work node和pod。多个master用来提供高可用服务。

![Components of Kubernetes](https://d33wubrfki0l68.cloudfront.net/817bfdd83a524fed7342e77a26df18c87266b8f4/3da7c/images/docs/components-of-kubernetes.png)

![img](https://blobscdn.gitbook.com/v0/b/gitbook-28427.appspot.com/o/assets%2F-LDAOok5ngY4pc1lEDes%2F-LpOIkR-zouVcB8QsFj_%2F-LpOIpZIYxaDoF-FJMZk%2Farchitecture.png?generation=1569161437087842&alt=media)

#### master组件

master提供了集群的控制服务，他们将会检测和回应集群的事件，例如当部署的replicas字段不符合要求的时候，将会启动一个新的pod。集群中的任何机器都可以作为master。

**kube-apiserver**

用来提供API服务，可以进行水平扩展，运行多个实例，提供了资源操作的唯一入口，并提供认证、授权、访问控制、API 注册和发现等机制。

**etcd**

[etcd](https://kubernetes.io/docs/admin/etcd) 用于 Kubernetes 的后端存储。所有集群数据都存储在此处，始终为您的 Kubernetes 集群的 etcd 数据提供备份计划。

**kube-scheduler**

监控新创建的pod，有没有节点分配，并且选择一个节点来运行。负责资源的调度，按照预定的调度策略将 Pod 调度到相应的机器上；

**kube-controller-manager**

从逻辑上讲，每个控制器是一个单独的进程，但是为了降低复杂性，它们都被编译为单个二进制文件并在单个进程中运行。负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；

- Node Controller:负责节点发生故障时的通知和响应；
- Replication Controller：负责为系统中的每个复制控制器对象维护正确数量的Pod。
- Endpoints Controller:Populates终端对象，joins Services & Pods
- Service Account & Token Controllers: 为新的namespaces创建默认的账户和API tokens。

**cloud-controller-manager**

#### 节点组件

运行在每个节点上，维护运行的pod，提供k8s运行时的环境。

**kubelet**

负责维护容器的生命周期，同时也负责 Volume（CVI）和网络（CNI）的管理。是代理，,它监测已分配给其节点的 Pod(通过 apiserver 或通过本地配置文件)，提供如下功能:

- 挂载 Pod 所需要的数据卷(Volume)。
- 下载 Pod 的 secrets。
- 通过 Docker 运行(或通过 rkt)运行 Pod 的容器。
- 周期性的对容器生命周期进行探测。
- 如果需要，通过创建 *镜像 Pod（Mirror Pod）* 将 Pod 的状态报告回系统的其余部分。
- 将节点的状态报告回系统的其余部分。

**kube-proxy**

[kube-proxy](https://kubernetes.io/docs/admin/kube-proxy)通过维护主机上的网络规则并执行连接转发，实现了Kubernetes服务抽象。负责为 Service 提供 cluster 内部的服务发现和负载均衡。

**container runtime**

k8s支持 [Docker](http://www.docker.com/), [containerd](https://containerd.io/), [cri-o](https://cri-o.io/), [rktlet](https://github.com/kubernetes-incubator/rktlet)。

#### Addons 插件

**DNS**：DNS是必须的。

WebUI，资源监控，集群级别的日志。



### 1.1.3 k8s 对象

我们可以使用yaml文件来表示k8s对象。

#### 理解k8s对象

**Object Spec and Status**

每个Kubernetes对象都包含两个嵌套的对象字段，它们控制着对象的配置：*spec*和status。您必须提供的规范描述了对象的所需状态-您希望对象具有的特征。状态描述了对象的实际状态，并由Kubernetes系统提供和更新。在任何给定时间，Kubernetes控制平面都会主动管理对象的实际状态以匹配您提供的所需状态。

Spec是必须提供的，描述了对象的期望状态，Status是实际的状态，由k8s进行更新。

**k8s对象的描述**

```yaml
application/deployment.yaml 

apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

我们可以使用`kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record`来创建一个对象。

上面这个文件中，哪些字段是必须的：

- apiVersion：创建对象的k8s API版本；
- kind：创建对象的类型；
- metadata:和其他对象进行区分
- spec：对象的期望状态

#### k8s对象管理

对比了三种方式的优缺点：

| Management technique             | Operates on          | Recommended environment | Supported writers | Learning curve |
| :------------------------------- | :------------------- | :---------------------- | :---------------- | :------------- |
| Imperative commands              | Live objects         | Development projects    | 1+                | Lowest         |
| Imperative object configuration  | Individual files     | Production projects     | 1                 | Moderate       |
| Declarative object configuration | Directories of files | Production projects     | 1+                | Highest        |

**Imperative commands**  

example：kubectl run nginx --image nginx

Trade-offs

Advantages compared to object configuration:

- Commands are simple, easy to learn and easy to remember.
- Commands require only a single step to make changes to the cluster.

Disadvantages compared to object configuration:

- Commands do not integrate with change review processes.
- Commands do not provide an audit trail associated with changes.
- Commands do not provide a source of records except for what is live.
- Commands do not provide a template for creating new objects.

**Imperative object configuration**

```sh
kubectl create -f nginx.yaml
```

Trade-offs

Advantages compared to imperative commands:

- Object configuration can be stored in a source control system such as Git.
- Object configuration can integrate with processes such as reviewing changes before push and audit trails.
- Object configuration provides a template for creating new objects.

Disadvantages compared to imperative commands:

- Object configuration requires basic understanding of the object schema.
- Object configuration requires the additional step of writing a YAML file.

Advantages compared to declarative object configuration:

- Imperative object configuration behavior is simpler and easier to understand.
- As of Kubernetes version 1.5, imperative object configuration is more mature.

Disadvantages compared to declarative object configuration:

- Imperative object configuration works best on files, not directories.
- Updates to live objects must be reflected in configuration files, or they will be lost during the next replacement.

**Declarative object configuration**

```sh
kubectl diff -f configs/
```

Trade-offs

Advantages compared to imperative object configuration:

- Changes made directly to live objects are retained, even if they are not merged back into the configuration files.
- Declarative object configuration has better support for operating on directories and automatically detecting operation types (create, patch, delete) per-object.

Disadvantages compared to imperative object configuration:

- Declarative object configuration is harder to debug and understand results when they are unexpected.
- Partial updates using diffs create complex merge and patch operations.

#### 推荐的label

| Key                            | Description                                                  | Example            | Type   |
| :----------------------------- | :----------------------------------------------------------- | :----------------- | :----- |
| `app.kubernetes.io/name`       | The name of the application                                  | `mysql`            | string |
| `app.kubernetes.io/instance`   | A unique name identifying the instance of an application     | `wordpress-abcxzy` | string |
| `app.kubernetes.io/version`    | The current version of the application (e.g., a semantic version, revision hash, etc.) | `5.7.21`           | string |
| `app.kubernetes.io/component`  | The component within the architecture                        | `database`         | string |
| `app.kubernetes.io/part-of`    | The name of a higher level application this one is part of   | `wordpress`        | string |
| `app.kubernetes.io/managed-by` | The tool being used to manage the operation of an application | `helm`             | string |

举个例子：

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/managed-by: helm
```



## 1.2 k8s 安装教程

我们将尝试在不同的环境来进行安装。

### 1.2.1 学习环境：

| Community                                                    | Ecosystem                                                    |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) | [CDK on LXD](https://www.ubuntu.com/kubernetes/docs/install-local) |
| [kind (Kubernetes IN Docker)](https://github.com/kubernetes-sigs/kind) | [Docker Desktop](https://www.docker.com/products/docker-desktop) |
|                                                              | [Minishift](https://docs.okd.io/latest/minishift/)           |
|                                                              | [MicroK8s](https://microk8s.io/)                             |
|                                                              | [IBM Cloud Private-CE (Community Edition)](https://github.com/IBM/deploy-ibm-cloud-private) |
|                                                              | [IBM Cloud Private-CE (Community Edition) on Linux Containers](https://github.com/HSBawa/icp-ce-on-linux-containers) |
|                                                              | [k3s](https://k3s.io/)                                       |
|                                                              | [Ubuntu on LXD](https://kubernetes.io/docs/getting-started-guides/ubuntu/) |

我们将尝试使用Minikube来安装：

Minikube可以在本地运行k8s。

#### 1.2.1.1 Minikube Features

- DNS
- NodePorts
- ConfigMaps and Secrets
- Dashboards
- Container Runtime: Docker, [CRI-O](https://cri-o.io/), and [containerd](https://github.com/containerd/containerd)
- Enabling CNI (Container Network Interface)
- Ingress

#### 1.2.1.2 安装

我是基于linux平台进行操作的。

1. 首先检查是否支持虚拟化。

```shell
grep -E --color 'vmx|svm' /proc/cpuinfo
```

2. 安装minikube

   1. 安装kubectl

      ```shell
      curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
      
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      kubectl version
      ```

   2. 安装Hypervisor

      也可以通过设置--vm-driver=none参数，来运行在主机上，注意的是，需要使用linux系统，并且需要安装docker。

   3. 安装minikube

      ```shell
      curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
        && chmod +x minikube
      sudo mkdir -p /usr/local/bin/
      sudo install minikube /usr/local/bin/
      ```

   4. 安装验证

      ```
      minikube start --vm-driver=none --image-mirror-country=cn
      minikube status
      ```

      记得国家指定为cn,毕竟是google的东西,不然你会启动失败的。

      如果还有印象的话，我们在前面kubectl version，的时候，是报了一个错误的，是说连不上服务，这是因为我们没有启动minikube。

      我也是很迷，不知道官网为啥是这样的顺序。

      如果想关闭的话，就这样：

      ```shell
      minikube stop
      minikube delete
      ```

      我们继续验证kubectl的状态,配置文件在~/.kube/config。

      ```shell
      kubectl cluster-info
      ```

      <img src="https://raw.githubusercontent.com/Anapodoton/ImageHost/master/img/20191211145542.png" style="zoom:50%;" />



#### 1.2.1.3 快速开始

1.   minikube start
2. 接下来使用kubectl和集群来交互，`kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.10`
3. 把hello-minikube作为服务暴露出去：`kubectl expose deployment hello-minikube --type=NodePort --port=8080`
4. 在使用之前需要检查这个pod的状态：kubectl get pod，我们需要等待状态变为Running。
5. 获取  服务暴露的url ：minikube service hello-minikube --url
6. 把url粘贴到浏览器中，看到如下的信息：
7. 删除服务：kubectl delete services hello-minikube
8. 删除部署环境：kubectl delete deployment hello-minikube
9. 停掉集群：minikube stop
10. 删除集群：minikube delete

### 1.2.2 生产环境

k8s可以支持docker,CRI-O,containerd等。



生产环境：

![Production environment solutions](https://d33wubrfki0l68.cloudfront.net/f6ca7c0c1ba895a1578b4131c0f174130a32c8b8/4b4c7/images/docs/kubernetessolutions.svg)

支持下面的生产环境：

| Providers                                                    | Managed                                                      | Turnkey cloud                                                | On-prem datacenter                                           | Custom (cloud)                                               | Custom (On-premises VMs)                                     | Custom (Bare Metal)                                          |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| [Agile Stacks](https://www.agilestacks.com/products/kubernetes) |                                                              | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |
| [Alibaba Cloud](https://www.alibabacloud.com/product/kubernetes) |                                                              | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [Amazon](https://aws.amazon.com/)                            | [Amazon EKS](https://aws.amazon.com/eks/)                    | [Amazon EC2](https://aws.amazon.com/ec2/)                    |                                                              |                                                              |                                                              |                                                              |
| [AppsCode](https://appscode.com/products/pharmer/)           | ✔                                                            |                                                              |                                                              |                                                              |                                                              |                                                              |
| [APPUiO](https://appuio.ch/)                                 | ✔                                                            | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |
| [Banzai Cloud Pipeline Kubernetes Engine (PKE)](https://banzaicloud.com/products/pke/) |                                                              | ✔                                                            |                                                              | ✔                                                            | ✔                                                            | ✔                                                            |
| [CenturyLink Cloud](https://www.ctl.io/)                     |                                                              | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [Cisco Container Platform](https://cisco.com/go/containers)  |                                                              |                                                              | ✔                                                            |                                                              |                                                              |                                                              |
| [Cloud Foundry Container Runtime (CFCR)](https://docs-cfcr.cfapps.io/) |                                                              |                                                              |                                                              | ✔                                                            | ✔                                                            |                                                              |
| [CloudStack](https://cloudstack.apache.org/)                 |                                                              |                                                              |                                                              |                                                              | ✔                                                            |                                                              |
| [Canonical](https://ubuntu.com/kubernetes)                   | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            |
| [Containership](https://containership.io/)                   | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [D2iQ](https://d2iq.com/)                                    |                                                              | [Kommander](https://d2iq.com/solutions/ksphere)              | [Konvoy](https://d2iq.com/solutions/ksphere/konvoy)          | [Konvoy](https://d2iq.com/solutions/ksphere/konvoy)          | [Konvoy](https://d2iq.com/solutions/ksphere/konvoy)          | [Konvoy](https://d2iq.com/solutions/ksphere/konvoy)          |
| [Digital Rebar](https://provision.readthedocs.io/en/tip/README.html) |                                                              |                                                              |                                                              |                                                              |                                                              | ✔                                                            |
| [DigitalOcean](https://www.digitalocean.com/products/kubernetes/) | ✔                                                            |                                                              |                                                              |                                                              |                                                              |                                                              |
| [Docker Enterprise](https://www.docker.com/products/docker-enterprise) |                                                              | ✔                                                            | ✔                                                            |                                                              |                                                              | ✔                                                            |
| [Fedora (Multi Node)](https://kubernetes.io/docs/getting-started-guides/fedora/flannel_multi_node_cluster/) |                                                              |                                                              |                                                              |                                                              | ✔                                                            | ✔                                                            |
| [Fedora (Single Node)](https://kubernetes.io/docs/getting-started-guides/fedora/fedora_manual_config/) |                                                              |                                                              |                                                              |                                                              |                                                              | ✔                                                            |
| [Gardener](https://gardener.cloud/)                          | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | [Custom Extensions](https://github.com/gardener/gardener/blob/master/docs/extensions/overview.md) |
| [Giant Swarm](https://www.giantswarm.io/)                    | ✔                                                            | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |
| [Google](https://cloud.google.com/)                          | [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/) | [Google Compute Engine (GCE)](https://cloud.google.com/compute/) | [GKE On-Prem](https://cloud.google.com/gke-on-prem/)         |                                                              |                                                              |                                                              |
| [IBM](https://www.ibm.com/in-en/cloud)                       | [IBM Cloud Kubernetes Service](https://cloud.ibm.com/kubernetes/catalog/cluster) |                                                              | [IBM Cloud Private](https://www.ibm.com/in-en/cloud/private) |                                                              |                                                              |                                                              |
| [Ionos](https://www.ionos.com/enterprise-cloud)              | [Ionos Managed Kubernetes](https://www.ionos.com/enterprise-cloud/managed-kubernetes) | [Ionos Enterprise Cloud](https://www.ionos.com/enterprise-cloud) |                                                              |                                                              |                                                              |                                                              |
| [Kontena Pharos](https://www.kontena.io/pharos/)             |                                                              | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |
| [KubeOne](https://kubeone.io/)                               |                                                              | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            |
| [Kubermatic](https://kubermatic.io/)                         | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            |                                                              |
| [KubeSail](https://kubesail.com/)                            | ✔                                                            |                                                              |                                                              |                                                              |                                                              |                                                              |
| [Kubespray](https://kubespray.io/#/)                         |                                                              |                                                              |                                                              | ✔                                                            | ✔                                                            | ✔                                                            |
| [Kublr](https://kublr.com/)                                  | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            | ✔                                                            |
| [Microsoft Azure](https://azure.microsoft.com/)              | [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) |                                                              |                                                              |                                                              |                                                              |                                                              |
| [Mirantis Cloud Platform](https://www.mirantis.com/software/kubernetes/) |                                                              |                                                              | ✔                                                            |                                                              |                                                              |                                                              |
| [Nirmata](https://www.nirmata.com/)                          |                                                              | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |
| [Nutanix](https://www.nutanix.com/en)                        | [Nutanix Karbon](https://www.nutanix.com/products/karbon)    | [Nutanix Karbon](https://www.nutanix.com/products/karbon)    |                                                              |                                                              | [Nutanix AHV](https://www.nutanix.com/products/acropolis/virtualization) |                                                              |
| [OpenNebula](https://www.opennebula.org/)                    | [OpenNebula Kubernetes](https://marketplace.opennebula.systems/docs/service/kubernetes.html) |                                                              |                                                              |                                                              |                                                              |                                                              |
| [OpenShift](https://www.openshift.com/)                      | [OpenShift Dedicated](https://www.openshift.com/products/dedicated/) and [OpenShift Online](https://www.openshift.com/products/online/) |                                                              | [OpenShift Container Platform](https://www.openshift.com/products/container-platform/) |                                                              | [OpenShift Container Platform](https://www.openshift.com/products/container-platform/) | [OpenShift Container Platform](https://www.openshift.com/products/container-platform/) |
| [Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE)](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm) | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [oVirt](https://www.ovirt.org/)                              |                                                              |                                                              |                                                              |                                                              | ✔                                                            |                                                              |
| [Pivotal](https://pivotal.io/)                               |                                                              | [Enterprise Pivotal Container Service (PKS)](https://pivotal.io/platform/pivotal-container-service) | [Enterprise Pivotal Container Service (PKS)](https://pivotal.io/platform/pivotal-container-service) |                                                              |                                                              |                                                              |
| [Platform9](https://platform9.com/)                          | [Platform9 Managed Kubernetes](https://platform9.com/managed-kubernetes/) |                                                              | [Platform9 Managed Kubernetes](https://platform9.com/managed-kubernetes/) | ✔                                                            | ✔                                                            | ✔                                                            |
| [Rancher](https://rancher.com/)                              |                                                              | [Rancher 2.x](https://rancher.com/docs/rancher/v2.x/en/)     |                                                              | [Rancher Kubernetes Engine (RKE)](https://rancher.com/docs/rke/latest/en/) |                                                              | [k3s](https://k3s.io/)                                       |
| [StackPoint](https://stackpoint.io/)                         | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [Supergiant](https://supergiant.io/)                         |                                                              | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [SUSE](https://www.suse.com/)                                |                                                              | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [SysEleven](https://www.syseleven.io/)                       | ✔                                                            |                                                              |                                                              |                                                              |                                                              |                                                              |
| [Tencent Cloud](https://intl.cloud.tencent.com/)             | [Tencent Kubernetes Engine](https://intl.cloud.tencent.com/product/tke) | ✔                                                            | ✔                                                            |                                                              |                                                              | ✔                                                            |
| [VEXXHOST](https://vexxhost.com/)                            | ✔                                                            | ✔                                                            |                                                              |                                                              |                                                              |                                                              |
| [VMware](https://cloud.vmware.com/)                          | [VMware Cloud PKS](https://cloud.vmware.com/vmware-cloud-pks) | [VMware Enterprise PKS](https://cloud.vmware.com/vmware-enterprise-pks) | [VMware Enterprise PKS](https://cloud.vmware.com/vmware-enterprise-pks) | [VMware Essential PKS](https://cloud.vmware.com/vmware-essential-pks) |                                                              | [VMware Essential PKS](https://cloud.vmware.com/vmware-essential-pks) |
| [Z.A.R.V.I.S.](https://zarvis.ai/)                           | ✔                                                            |                                                              |                                                              |                                                              |                                                              |                                                              |

## 1.3 Workloads

### 1.3.1 Pods

#### 1.3.1.1 Pod Overview

pod是k8s对象模型中的最小可部署对象。

Pod 是一组紧密关联的容器集合，它们共享 PID、IPC、Network 和 UTS namespace，是 Kubernetes 调度的基本单位。Pod 内的多个容器共享网络和文件系统，可以通过进程间通信和文件共享这种简单高效的方式组合完成服务。![img](https://blobscdn.gitbook.com/v0/b/gitbook-28427.appspot.com/o/assets%2F-LDAOok5ngY4pc1lEDes%2F-LpOIkR-zouVcB8QsFj_%2F-LpOIpZEWjsArXqZpSuN%2Fpod.png?generation=1569161437022859&alt=media)



##### 1.3.1.1.1 Pods的理解

pod是k8s的基本执行单元，一个pod代表了运行在集群上的一个进程。pod包括了一个或者多个容器，存储资源，唯一的IP。

- **Pods that run a single container**：是最常见的；
- 多个容器一个pod：

##### 1.3.1.1.2 Pods管理多个容器



<img src="https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg" alt="example pod diagram" style="zoom:25%;" />

每个pod都有一个IP地址，pod中的容器共享IP地址和端口，pod内部的容器可以相互通信，此外，存储是可以共享的。

##### 1.3.1.1.3 pod模板

```
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```

Node 是 Pod 真正运行的主机，可以是物理机，也可以是虚拟机。为了管理 Pod，每个 Node 节点上至少要运行 container runtime（比如 docker 或者 rkt）、`kubelet` 和 `kube-proxy` 服务。

![img](https://blobscdn.gitbook.com/v0/b/gitbook-28427.appspot.com/o/assets%2F-LDAOok5ngY4pc1lEDes%2F-LpOIkR-zouVcB8QsFj_%2F-LpOIpZNK7_D9lT7C57d%2Fnode.png?generation=1569161441558542&alt=media)

Namespace 是对一组资源和对象的抽象集合，比如可以用来将系统内部的对象划分为不同的项目组或用户组。常见的 pods, services, replication controllers 和 deployments 等都是属于某一个 namespace 的（默认是 default），而 node, persistentVolumes 等则不属于任何 namespace。

Service 是应用服务的抽象，通过 labels 为应用提供负载均衡和服务发现。匹配 labels 的 Pod IP 和端口列表组成 endpoints，由 kube-proxy 负责将服务 IP 负载均衡到这些 endpoints 上。

每个 Service 都会自动分配一个 cluster IP（仅在集群内部可访问的虚拟地址）和 DNS 名，其他容器可以通过该地址或 DNS 来访问服务，而不需要了解后端容器的运行。

![img](https://blobscdn.gitbook.com/v0/b/gitbook-28427.appspot.com/o/assets%2F-LDAOok5ngY4pc1lEDes%2F-LpOIkR-zouVcB8QsFj_%2F-LpOIpZQ8P49qNDyiHUJ%2F14731220608865.png?generation=1569161437146749&alt=media)



```
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - port: 8078 # the port that this service should serve on
    name: http
    # the container on each pod to connect to, can be a name
    # (e.g. 'www') or a number (e.g. 80)
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx
```

Label 是识别 Kubernetes 对象的标签，以 key/value 的方式附加到对象上（key 最长不能超过 63 字节，value 可以为空，也可以是不超过 253 字节的字符串）。

Label 不提供唯一性，并且实际上经常是很多对象（如 Pods）都使用相同的 label 来标志具体的应用。

Label 定义好后其他对象可以使用 Label Selector 来选择一组相同 label 的对象（比如 ReplicaSet 和 Service 用 label 来选择一组 Pod）。Label Selector 支持以下几种方式：

- 等式，如 `app=nginx` 和 `env!=production`
- 集合，如 `env in (production, qa)`
- 多个 label（它们之间是 AND 关系），如 `app=nginx,env=test`

Annotations 是 key/value 形式附加于对象的注解。不同于 Labels 用于标志和选择对象，Annotations 则是用来记录一些附加信息，用来辅助应用部署、安全策略以及调度策略等。比如 deployment 使用 annotations 来记录 rolling update 的状态。

# 后记

我知道Docker是怎么回事，但是不太清楚Kubernetes究竟在干什么，它要解决什么问题？有哪些功能？在网上搜索了一些文章，可是都无法让我满意，因为他们都是非常宏观地讲一讲，然后马上就进入使用细节，让人还是云里雾里。 

之前我就说过，想深入地了解一门技术，最好的办法就是看书，于是就去购书中心转了一圈，发现一本书籍《Kubernetes in Action》，翻了一会儿我就觉得这本书不错，就拿它来学习吧。 

这本书一开始就提到了微服务，这是个非常好的切入点，我脑海中立刻想到了微服务的特点，可以独立部署，轻松扩容。

那扩容的时候具体该怎么做呢？例如有个订单服务，我想把部署10份，难道我跑到服务器端，手工启动10个实例？

这肯定不符合自动化运维的方式，也许可以写个脚本，接受一个参数或者读取配置文件，把实例自动创建起来。 

但是仔细一想，这样是不行的，因为现实中会有很多服务器，脚本怎么去管理呢？脚本怎么获取它们的IP以及它们的负载情况，然后把Docker实例分发创建到合适的服务器中呢？ 

于是第一个猜测来了：

**最好是有个系统，它能管理所有的服务器，我只要告诉他，把订单服务的docker镜像部署10份，剩下的事情就不用我管了，都由这个系统来搞定。**

这时候我隐隐约约地感觉到了Kubernetes的核心功能。 

于是我跳过了微服务的介绍，Docker的介绍，这些都是老掉牙的东西了，迅速翻到了第16页：

![img](data:image/jpeg;base64,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)

这幅图画得相当棒，清楚地展示了K8s的核心功能，但是仔细看以后，就发现有两个微服务被放到了一起，作为一个整体来部署，这是我之前没有想到的！ 

**部署的最小粒度并不是Docker镜像，而是另外一个东西**！从系统设计的角度来看，必须得有个词来表达，这个东西是什么？ 

于是我又往后翻，哦，原来这个词叫做pod。 

作者告诉我在第3章有详细介绍，我迫不及待地往后翻，试图满足好奇心：pod到底是什么东西。 

**原来这些pod就像局域网中的一个个独立的逻辑主机啊，每个Docker实例都是一个进程**。 

![image-20191213193102001](https://tva1.sinaimg.cn/large/006tNbRwly1g9vbn9f8c3j312u0jkb29.jpg)

—个pod的所有容器都运行在同—个节点上; 一个pod绝不跨越两个节点 。

关于为何需要pod这种容器?为何不直接使用容器?为何甚至需要同时运行 多个容器?难道不能简单地把所有进程都放在 一 个单独的容器中吗? 

到目前为止，我就明白了**k8s本质上是一层抽象，这一层抽象屏蔽了服务器的细节**，程序员不需要知道程序运行在哪个服务器上，只需要告诉k8s自己的需求就好。 

那用什么方式来告诉k8s呢？这很容易猜测到，可以: 

1. 通过命令行参数传递给k8s, 但是参数太受限。 

2. 用配置文件，在其中可以指明pod的名称，docker的镜像名称......  可以用XML格式， JSON格式，YAML格式.....  

当然，这些念头都是一闪而过，我翻开这本书的第3章，主要讲pod，果然是用YAML,JSON去创建pod, 由于已经预料到了，没什么新意，稍微看了看就跳过。 

让我没有想到的是可以使用**标签**和**命名空间**对pod进行分组，但是讲解有点啰嗦，似乎也不是核心概念，稍微翻了一下就过去了。 

稍等 ！为什么不在创建pod的时候指定pod的数量啊？比如我想创建10个订单服务的docker实例，在哪里指定？仔细看看那些YAML文件，确实没有副本数量，这k8s搞什么鬼？这里没有指定，肯定在别的地方，那就是说：

除了pod之外，还有一个概念，用来指定pod和副本之间的关系，这个概念是什么？



快速翻到第4章，哈哈，原来这个概念叫做ReplicationController（简称RC），由它来保证pod的数目符合要求，多了就删除，少了就添加。 

![image-20191213194026344](https://tva1.sinaimg.cn/large/006tNbRwly1g9vbx1p3v5j313c0twb2a.jpg)

从设计角度来看，再次体现了**关注点分离**，**pod负责“静态描述”，像一个模板，就像class， RC负责运行时管理，来产生pod的object**。 

创建RC也是使用YAML，比较让我意外的是，在指定pod时，用了前面所讲的标签，看来标签是组织pod的重要方法，有时间回去看看细节。 

需要注意的是，在管理pod数目的时候，用的是声明式：“我想要运行10个订单实例”， 而不是“我想增加3个订单实例”或“我想删除3个订单实例”。 你不用告诉k8s做什么、如何做，**只是指定期望的状态就好**。

如果你也善于思考的话，这时候就会冒出了一个新问题： 

这些pod 不断地被删除，被增加，不断地变化，那外界怎么去访问他们呢？ 

比如客户端正在访问pod1,然后pod1所在的机器挂掉，ReplicationController在另外一台机器上创建了pod2，IP都变了，那客户端下一次去访问pod2呢？ 

如果让我设计，我肯定得提供另外一个抽象层，**让这个抽象层来屏蔽后端的变化，让客户端连接到这个抽象层上**。 

k8s 会怎么做呢？第4章给出了答案：**服务**。 我个人觉得这个词起得不好，太抽象，太广泛。 

![image-20191213194501754](https://tva1.sinaimg.cn/large/006tNbRwly1g9vc1u0konj311m0quqv5.jpg)

可以看出，**k8s和其他系统一样，也是不断地通过分离关注点，不断地抽象来解决一个个问题的**。

到目前为止，我脑海中想的都是那些“**无状态**”的pod，可以随意增加和删除， 但肯定存在“**有状态**”的pod，有持久化的需求，可以把数据存储到硬盘上，这该怎么办？ 

带着这个问题，继续上路吧！ 

好了，啰嗦了这么多，稍微总结一下：我希望给大家分享的就是，**看书的时候要主动思考，不要被动接受**。

**带着问题去看，自己先想想解决方案，然后到书中去验证，效率会非常高，读起来会非常快。**

如果自己的问题在书中很快就得到回答，那读起来就会酣畅淋漓；如果迟迟得不到回答，或者书中一直不厌其烦地描述细枝末节，那我很快就丧失兴趣，把书扔掉。 

当然，由于每个人的基础不同，可能刚开始读书的时候提不出问题，或者提不出有价值的问题，这时候可以去直接看具体内容，但是不能放弃思考：这个技术点是要解决什么问题的？是怎么解决的？

希望每个人都建立一套自己的知识体系，从这个知识体系中能伸出很多的触角，能像海绵一样吸收外界的知识，不断地为自己的知识体系添砖加瓦。













