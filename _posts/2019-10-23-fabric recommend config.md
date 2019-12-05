---
layout: post
title: "2019-10-23-Fabric部署注意事项"
date: 2019-10-23
description: "2019-10-23-Fabric部署注意事项"
categories: fabric
tag: fabric
---
**Fabric部署注意事项**

**【持续更新】**https://app.yinxiang.com/fx/8dd0ae6e-6c04-4b1d-9b84-a885b789fc92

【1、锚节点】每个通道至少有一个锚节点，**强烈建议**每个通道中的每个组织都要设置一个锚节点。

例子：mychannel中有Org1和Org2两个组织，yourchannel中有Org1和Org2两个组织。那么我们需要设置4个锚节点。比如Org1MyChannelMSPanchors.tx,Org2MyChannelMSPanchors.tx,Org1YourChannelMSPanchors.tx,Org2YourChannelMSPanchors.tx。

【原文】As communication across organizations depends on gossip in order to work, there must be at least one anchor peer defined in the channel configuration. It is strongly recommended that every organization provides its own set of anchor peers for high availability and redundancy. Note that the anchor peer does not need to be the same peer as the leader peer.

【2、kafka集群】kafka集群的数量至少为4（如果少于4个，当一个kafka宕机的时候，会出现无法创建channel的情况），zookeeper集群的数量为3，5，7（ 必须是奇数，避免脑裂，此外也不要超过7个）

[原文]At a minimum, K should be set to 4. (As we will explain in Step 4 below, this is the minimum number of nodes necessary in order to exhibit crash fault tolerance, i.e. with 4 brokers, you can have 1 broker go down, all channels will continue to be writeable and readable, and new channels can be created.)



Z will either be 3, 5, or 7. It has to be an odd number to avoid split-brain scenarios, and larger than 1 in order to avoid single point of failures. Anything beyond 7 ZooKeeper servers is considered overkill. 

【3、Private data】policy，private data的policy必须比链码的背书策略更加广泛。requiredPeerCount：不建议为0 。maxPeerCount不建议为0. 

【原文】

To support read/write transactions, the private data distribution policy must define a broader set of organizations than the chaincode endorsement policy, as peers must have the private data in order to endorse proposed transactions. 

A requiredPeerCount of 0 would typically not be recommended, as it could lead to loss of private data in the network if the endorsing peer(s) becomes unavailable. 

【4、通道配置修改】强烈建议获取channel中**所有组织**的签名后再更新配置文件。

【原文】The other option is to submit the update to every Admin on a channel and wait for enough signatures to come back. These signatures can then be stitched together and submitted. This makes life a bit more difficult for the Admin who created the config update (forcing them to deal with a file per signer) but is the recommended workflow for users which are developing Fabric management applications.

【5、CouchDB】couchdb数据库和peer节点运行在相同的服务器上，不要把couchdb容器的端口暴露出去。 

密码不建议写死，使用环境变量来传递。 

【原文】 

*# It is recommended to run CouchDB on the same server as the peer, and*

   *# not map the CouchDB container port to a server port in docker-compose.* 

   *# Otherwise proper security must be provided on the connection between* 

*# CouchDB client (on the peer) and server.*

建议开启索引。

To leverage the major benefit of CouchDB – the ability to perform rich queries against JSON data – indexes are not required, but they are strongly recommended for performance. Also, if sorting is required in a query, CouchDB requires an index of the sorted fields.

【6、organizations】组织和MSPs需要一一对应。

We recommend that there is a one-to-one mapping between organizations and MSPs. 

【7、系统channel】系统channel创世块的配置中不应该定义Application部分。

【原文】It is recommended never to define an Application section inside of the ordering system channel genesis configuration, but may be done for testing. Note that any member with read access to the ordering system channel may see all channel creations, so this channel’s access should be restricted.

【8、tls】强烈建议开启tls。

It is highly recommended to enable mutual TLS by setting the value of clientAuthRequired to true in production environments

【9、链码的开发者模式】生产环境中不建议开启。即CORE_VM_DOCKER_ATTACHSTDOUT=false

Once enabled, each chaincode will receive its own logging channel keyed by its container-id. Any output written to either stdout or stderr will be integrated with the peer’s log on a per-line basis. It is not recommended to enable this for production.