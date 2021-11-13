---
layout: post
title: "fabric性能测试工具"
date: 2021-03-15
description: "2021-03-15-fabric-type"
categories: fabric
tag: [fabric]
---

# 前言

[参考](https://github.com/Hyperledger-TWGC/tape/blob/master/README.md)

Tape 一款轻量级 Hyperledger Fabric 性能测试工具。Hyperledger Caliper是更加完整的测试工具。

# 安装

1. Download binary: get release tar from [release page](https://github.com/guoger/tape/releases), and extract `tape` binary from it
2. Build from source: clone this repo and run `make tape` at root dir. Go1.14 or higher is required. `tape` binary will be available at project root directory.
3. Pull docker image: `docker pull guoger/tape`

# 快速开始

```
./tape config.yaml 40000
```

使用 config.yaml 作为配置文件，向 Fabric 网络发送40000条交易进行性能测试。

注意这个40000需要是**Fabric 中 Peer 节点的配置文件 core.yaml** 中**batchsize**的整数倍。



# 配置文件详解

我们为 Tape 提供了一个示例配置文件 `config.yaml`，你可以在项目根据下找到它。使用 Tape 进行测试之前，请根据您的区块链网络情况修改该配置文件。

`config.yaml` 示例配置文件如下所示：

```
# Definition of nodes
peer1: &peer1
  addr: localhost:7051
  tls_ca_cert: ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

peer2: &peer2
  addr: localhost:9051
  tls_ca_cert: ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem

orderer1: &orderer1
  addr: localhost:7050
  tls_ca_cert: ./organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Nodes to interact with
endorsers:
  - *peer1
  - *peer2
# we might support multi-committer in the future for more complex test scenario,
# i.e. consider tx committed only if it's done on >50% of nodes. But for now,
# it seems sufficient to support single committer.
committer: *peer2
orderer: *orderer1

# Invocation configs
channel: mychannel
chaincode: basic
args:
  - GetAllAssets
mspid: Org1MSP
private_key: ./organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/priv_sk
sign_cert: ./organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem
num_of_conn: 10
client_per_conn: 10
```

接下来我们将逐一解析该配置文件的含义。

首先，前三个部分：

```
# Definition of nodes
peer1: &peer1
  addr: localhost:7051
  tls_ca_cert: ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

peer2: &peer2
  addr: localhost:9051
  tls_ca_cert: ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem

orderer1: &orderer1
  addr: localhost:7050
  tls_ca_cert: ./organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

定义了不同的节点，包括 Peer 节点和排序节点，配置中需要确认节点地址以及 TLS CA 证书（如果启用 TLS，则必须配置 TLS CA 证书）。其中节点地址格式为`地址:端口`。此处`地址`推荐使用域名，因此您可能还需要在 hosts 文件中增加节点域名和 IP 的映射关系。

如果启用了双向 TLS，即你的 Fabric 网络中的 Peer 节点在 core.yaml 配置了 "peer->tls->clientAuthRequired" 为 "true"，则表明，不但服务端（Peer 节点）向客户端（Tape）发送的信息是经过加密的，客户端（Tape）向服务端（Peer 节点）发送的信息也应该是加密的，因此我们就需要在配置文件中增加 TLS 通信中需要使用的密钥，双向 TLS 配置示例如下：

```
peer1: &peer1
  addr: localhost:7051
  tls_ca_cert: ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem
  tls_ca_key: ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
  tls_ca_root: ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt

peer2: &peer2
  addr: localhost:9051
  tls_ca_cert: ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem
  tls_ca_key: ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
  tls_ca_root: ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt

orderer1: &orderer1
  addr: localhost:7050
  tls_ca_cert: ./organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  tls_ca_key: ./organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/tls/server.key
  tls_ca_root: ./organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/tls/server.crt
```

其中三个 TLS 相关的证书/密钥说明如下：

- `tls_ca_cert`：客户端 TLS 通信时使用的证书文件。
- `tls_ca_key`：客户端 TLS 通信时使用的私钥文件。
- `tls_ca_root`：CA 根证书文件。

接下来的三个部分：

```
# Nodes to interact with
endorsers:
  - *peer1
  - *peer2
# we might support multi-committer in the future for more complex test scenario,
# i.e. consider tx committed only if it's done on >50% of nodes. But for now,
# it seems sufficient to support single committer.
committer: *peer2
orderer: *orderer1
```

分别定义了角色为背书节点（endorsers）、提交节点（committer）和排序节点（orderer）的节点。

`endorsers`: 负责为交易提案背书的节点，Tape 会把构造好的已签名的交易提案发送到背书节点进行背书。

`committer`: 负责接收其他节点广播的区块提交成功的信息。

`orderer`: 排序节点，目前 Tape 仅支持向一个排序节点发送交易排序请求。

Tape 以 Fabric 用户的身份向区块链网络发送交易，所以还需要下边的配置：

```
# Invocation configs
channel: mychannel
chaincode: basic
args:
  - GetAllAssets
mspid: Org1MSP
private_key: ./organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/priv_sk
sign_cert: ./organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem
num_of_conn: 10
client_per_conn: 10
```

`channel`：通道名。

`chaincode`：要调用的链码名。

`args`：要调用的链码的参数。参数取决于链码实现，例如，fabric-samples 项目中提供的示例链码 [abac](https://github.com/hyperledger/fabric-samples/blob/master/chaincode/abac/go/abac.go) ，其功能为账户A和账户B之间的转账。如果想要以此链码作为性能测试的链码，执行操作为账户A向账户B转账10，则参数设置如下：

```
args:
  - invoke
  - a
  - b
  - 10
```

`mspid`：MSP ID 是用户属性的一部分，表明该用户所属的组织。

`private_key`：用户私钥的路径。如果你使用 BYFN 作为你的测试网络，私钥路径为 `crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/priv_sk` 。

`sign_cert`：用户证书的路径。如果你使用 BYFN 作为你的测试网络，私钥路径为 `crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem` 。

`num_of_conn`：客户端和 Peer 节点，客户端和排序节点之间创建的 gRPC 连接数量。如果你觉得向 Fabric 施加的压力还不够，可以将这个值设置的更大一些。

`client_per_conn`：每个连接用于向每个 Peer 节点发送 提案的客户端数量。如果你觉得向 Fabric 施加的压力还不够，可以将这个值设置的更大一些。所以 Tape 向 Fabric 发送交易的并发量为 `num_of_conn` * `client_per_conn`。

# 性能白皮书

- 交易吞吐量

***交易吞吐量 = 已提交的交易总数 / 总时间(秒) @ #已提交节点***

交易吞吐量是区块链SUT在指定的时间范围内提交有效交易的速率。注意，这不是单个节点的速率，而是整个SUT的速率，即在网络的所有节点上提交的速率。这个速率表示为以网络大小计算的每秒交易数(TPS)。

















