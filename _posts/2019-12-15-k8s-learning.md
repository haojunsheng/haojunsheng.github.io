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

Kubernetes是一个可移植的，可扩展的开源平台，用于管理容器化的workloads 和 services。它拥有一个庞大且快速增长的生态系统。Kubernetes的服务，工具广泛可用。

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

用来备份集群数据的高可用的数据库。

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

是代理，确保容器运行在pod中，kubelet包含通过各种机制提供的一组PodSpec，并确保这些PodSpec中描述的容器运行正常。Kubelet不管理非Kubernetes创建的容器。

**kube-proxy**



**container runtime**

k8s支持 [Docker](http://www.docker.com/), [containerd](https://containerd.io/), [cri-o](https://cri-o.io/), [rktlet](https://github.com/kubernetes-incubator/rktlet)。

#### Addons 插件

**DNS**：DNS是必须的。

WebUI，资源监控，集群级别的日志。



### 1.1.3 k8s 对象

#### 理解k8s对象

**Object Spec and Status**

每个Kubernetes对象都包含两个嵌套的对象字段，它们控制着对象的配置：*spec*和status。您必须提供的规范描述了对象的所需状态-您希望对象具有的特征。状态描述了对象的实际状态，并由Kubernetes系统提供和更新。在任何给定时间，Kubernetes控制平面都会主动管理对象的实际状态以匹配您提供的所需状态。

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



## Kubernetes Objects

基本的k8s对象：

要使用Kubernetes，您可以使用Kubernetes API对象来描述集群的期望状态：您要运行哪些应用程序或其他工作负载，它们使用哪些容器映像，副本数量，要使其可用的网络和磁盘资源。您可以通过使用Kubernetes API（通常是通过命令行界面kubectl）创建对象来设置所需的状态。您还可以直接使用Kubernetes API与集群进行交互并设置或修改所需的状态。

设置所需的状态后，Kubernetes *Control Plan* 将通过Pod生命周期事件生成器（PLEG）使集群的当前状态与所需的状态匹配。为此，Kubernetes自动执行各种任务，例如启动或重新启动容器，扩展给定应用程序的副本数量等等。Kubernetes Control Plane 由集群上运行的一系列进程组成：

- **Kubernetes Master**:是运行在集群中的节点，由三个进程组成， [kube-apiserver](https://kubernetes.io/docs/admin/kube-apiserver/), [kube-controller-manager](https://kubernetes.io/docs/admin/kube-controller-manager/) and [kube-scheduler](https://kubernetes.io/docs/admin/kube-scheduler/).
- 每个独立的非master节点：由2个进程组成
  - **[kubelet](https://kubernetes.io/docs/admin/kubelet/)**, 和master节点通信
  - **[kube-proxy](https://kubernetes.io/docs/admin/kube-proxy/)**, 网络代理