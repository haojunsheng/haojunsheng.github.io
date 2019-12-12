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

#### master组件

master提供了集群的控制服务，他们将会检测和回应集群的事件，例如当部署的replicas字段不符合要求的时候，将会启动一个新的pod。集群中的任何机器都可以作为master。

**kube-apiserver**

用来提供API服务，可以进行水平扩展，运行多个实例。

**etcd**

[etcd](https://kubernetes.io/docs/admin/etcd) 用于 Kubernetes 的后端存储。所有集群数据都存储在此处，始终为您的 Kubernetes 集群的 etcd 数据提供备份计划。

**kube-scheduler**

监控新创建的pod，有没有节点分配，并且选择一个节点来运行。

**kube-controller-manager**

从逻辑上讲，每个控制器是一个单独的进程，但是为了降低复杂性，它们都被编译为单个二进制文件并在单个进程中运行。

- Node Controller:负责节点发生故障时的通知和响应；
- Replication Controller：负责为系统中的每个复制控制器对象维护正确数量的Pod。
- Endpoints Controller:Populates终端对象，joins Services & Pods
- Service Account & Token Controllers: 为新的namespaces创建默认的账户和API tokens。

**cloud-controller-manager**

#### 节点组件

运行在每个节点上，维护运行的pod，提供k8s运行时的环境。

**kubelet**

是代理，,它监测已分配给其节点的 Pod(通过 apiserver 或通过本地配置文件)，提供如下功能:

- 挂载 Pod 所需要的数据卷(Volume)。
- 下载 Pod 的 secrets。
- 通过 Docker 运行(或通过 rkt)运行 Pod 的容器。
- 周期性的对容器生命周期进行探测。
- 如果需要，通过创建 *镜像 Pod（Mirror Pod）* 将 Pod 的状态报告回系统的其余部分。
- 将节点的状态报告回系统的其余部分。

**kube-proxy**

[kube-proxy](https://kubernetes.io/docs/admin/kube-proxy)通过维护主机上的网络规则并执行连接转发，实现了Kubernetes服务抽象。

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



