---
layout: post
title: "Fabric 2.0新特性"
date: 2020-02-01
description: "2020-02-01-Fabric 2.0新特性"
categories: fabric
tag: fabric

---


# 前言

> 链码不需要“实例化”，可以同时运行java和go链码，同一个链码多次实例化。

想要了解上面的特性，请看下面的分解。

Fabric 2.0 在2020年1月29号终于release了，我们来看下有哪些新的变化。

主要体现在：对新应用和隐私的支持，增强了智能合约的管理，增加了对节点的操作。

需要注意的是，只能由fabric-1.4.x升级到2.0。

ps：在网上有个翻译，那一字一句的翻译，真的让我很难受。

下面我尝试使用自己的理解来解读。

# 1. 智能合约的去中心化管理

fabric 2.0引入了智能合约的去中心化管理，在此之前，链码的安装和实例化都是一个由组织在操作，现在则发生了变化。新的链码的生命周期中，只有多个组织达成了共识，才可以和账本才可以进行交互。

- **多个组织必须同意链码的参数**。在2.0之前，一个组织可以为channel中的所有成员设置链码的参数（例如实例化链码时指定的背书策略），拒绝安装链码的组织将不能参与链码的调用。在2.0中，同时提供中心化的模型和去中心化的模型。
- **链码的升级更加安全**。在之前的链码生命周期中，一个组织即可升级链码。在新的版本中，需要别的组织进行同意。
- **简化了背书策略和private data的更新**。我们不必重新打包/安装链码即可更新背书策略和private data集合的配置。同时我们设置了默认的背书策略，默认的背书策略在我们增加或者删除组织的时候会自动生效。
- 打包链码：会打包为tar文件，方便进行阅读。
- 一次打包多次复用：之前链码是通过名字+版本号来决定的，现在一次打包生成多个名字，可以多次安装（在相同或者不同的通道上）
- 不需要所有人的同意即可打包chaincode：组织可以扩展链码，不需要所有人的同意，只要符合背书要求，这些交易即可被更新到账本中。这样做的好处是，不需要所有人的同意，即可小规模的修改链码的bug。

## 1.1 链码新的生命周期

### 1.1.1 链码的安装和定义

新的链码周期要求组织对链码的名字，版本，背书策略达成一致，需要执行以下四步，但不需要每个组织都执行：

- 打包链码：一个或者每一个组织完成。
- 自己的节点安装链码。每个组织要执行，因为需要交易或者查询账本。
- 同意链码的定义：需要满足channel LifecycleEndorsment（默认是大多数）策略的足够数量的组织来执行。
- 提交chaincode的定义：第一个收集到足够数量的节点来执行。

下面来详细的看上面4步：

#### 1.1.1.1 打包链码

链码在安装前需要打包为tar文件。我们可以使用peer命令，node sdk，或者第三方工具。

第三方的打包工具需要满足以下要求：

- 链码以tar.gz结尾；
- tar文件需要包含2个文件（不是目录），元文件Chaincode-Package-Metadata.json和chaincode文件。
- Chaincode-Package-Metadata.json文件长成下面这样。

- ```
  {"Path":"fabric-samples/chaincode/fabcar/go","Type":"golang","Label":"fabcarv1"}
  ```

一个demo如下。2个组织不需要使用相同的名字。

![Packaging the chaincode](/images/posts/fabric/Lifecycle-package.png)

#### 1.1.1.2 安装链码

每个节点上都需要安装。强烈建议每个组织只打包一次链码，然后把该链码安装在该组织的所有节点上。如果一个channel想要保证所有的组织运行相同的链码，那么打包命令应该由一个组织来进行。

安装成功后会返回*MYCC_1:hash.*这样的格式，我们需要进行保存，方便后面的使用，如果忘记了，可以进行查询。

![Installing the chaincode](/images/posts/fabric/Lifecycle-install.png)

#### 1.1.1.3 同意链码的定义

我的理解是，在上面，每个组织都给chaincode起了一个名字，这样，在实际中是无法使用的，所以现在大家来投票来确定一个统一的名字，包含下面的参数：

- 名字
- 版本：chaincode打包的时候生成的。
- **Sequence**：用来追踪链码的升级过程。是自增的。
- 背书策略：哪些组织可以执行可以验证交易。
- **Collection Configuration:**私有数据相关。
- **Initialization**：原来chaincode的默认的init函数不执行，现在可以了。
- **ESCC/VSCC Plugins**



![Approving the chaincode definition](/images/posts/fabric/Lifecycle-approve.png)

#### 1.1.1.4 提交链码的定义

 一旦得到了绝大多数成员的同意，就可以提交链码的定义了。

我们可以使用checkcommitreadiness命令来检查是否已经有链码的定义了，首先会发送给所有的peer节点，在发送给order节点。提交必须是组织的管理员来完成的。

Channel/Application/LifecycleEndorsement来管理认可的组织的数量，默认是大多数。LifecycleEndorsement和chaincode的背书策略是分离的，没有任何关系的。

![Committing the chaincode definition to the channel](/images/posts/fabric/Lifecycle-commit.png)

即使一个组织没有安装链码，仍然可以响应链码的定义。

当链码的定义被确认后，将会在所有安装链码的节点上启动链码容器。如果我们在定义链码的时候要求使用init函数，那么init函数将会被调用。

![Starting the chaincode on the channel](/images/posts/fabric/Lifecycle-start.png)

### 1.1.2 链码的升级

升级和安装类似，我们既可以升级链码的内容，还可以升级链码的背书策略。

1. 打包链码。只有在升级链码内容的时候需要。

   ![Re-package the chaincode package](/images/posts/fabric/Lifecycle-upgrade-package-20200217233850395.png)

2. 安装新链码。同上。

   ![Re-install the chaincode package](/images/posts/fabric/Lifecycle-upgrade-install.png)

3. 链码定义投票。**sequence**将会自增1。

   ![Approve a new chaincode definition](https://hyperledger-fabric.readthedocs.io/en/release-2.0/_images/Lifecycle-upgrade-approve.png)

4. 提交定义。

   ![Commit the new definition to the channel](/images/posts/fabric/Lifecycle-upgrade-commit.png)

将会启动新的链码容器。

![Upgrade the chaincode](/images/posts/fabric/Lifecycle-upgrade-start.png)

### 1.1.3 完整的demo

下面是chaincode的比较完整的操作。来自[fabric-samples](https://github.com/hyperledger/fabric-samples/blob/master/test-network/scripts/deployCC.sh)。

```shell
## at first we package the chaincode
packageChaincode 1

## Install chaincode on peer0.org1 and peer0.org2
echo "Installing chaincode on peer0.org1..."
installChaincode 1
echo "Install chaincode on peer0.org2..."
installChaincode 2

## query whether the chaincode is installed
queryInstalled 1

## approve the definition for org1
approveForMyOrg 1

## check whether the chaincode definition is ready to be committed
## expect org1 to have approved and org2 not to
checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": false"
checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": false"

## now approve also for org2
approveForMyOrg 2

## check whether the chaincode definition is ready to be committed
## expect them both to have approved
checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": true"
checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": true"

## now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition 1 2

## query on both orgs to see that the definition committed successfully
queryCommitted 1
queryCommitted 2

## Invoke the chaincode
chaincodeInvokeInit 1 2

sleep 10

## Invoke the chaincode
chaincodeInvoke 1 2

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1..."
chaincodeQuery 1
```

下面来看图：

**加入通道**：如果一个channel已经有了定义好的chaincode，那么新加入的组织在安装链码后可以直接使用原来的名字。

![Approve a chaincode definition](/images/posts/fabric/Lifecycle-join-approve.png)

如果背书策略是默认的大多数，那么背书策略会自动更新，把新的组织计算在内。

![Start the chaincode](/images/posts/fabric/Lifecycle-join-start.png)

**升级背书策略**

我们不必重新打包或者安装链码即可升级背书策略。channel中的成员会重新生成一个chaincode定义。

![Approve new chaincode definition](/images/posts/fabric/Lifecycle-endorsement-approve.png)

新的背书策略在新的链码定义通过后，即可生效，我们不必重启容器即可更新背书策略。

![Commit new chaincode definition](/images/posts/fabric/Lifecycle-endorsement-commit.png)

无法安装链码即可同意链码的定义：

![Org3 does not install the chaincode](/images/posts/fabric/Lifecycle-no-package.png)

不同意链码定义的组织将不能使用链码：

![Org3 does not install the chaincode](/images/posts/fabric/Lifecycle-no-package-20200217235444051.png)

上图中的组织三不可以使用链码。

channel不认可链码的定义：这里比较绕，说的是channel中的组织没有对链码的定义达成共识。

![Majority disagree on the chaincode](/images/posts/fabric/Lifecycle-majority-disagree.png)

组织安装了不同类型的链码：这里的意思是说只要链码产生相同的读写集，那么可以安装不同语言写的链码，比如java和go。

![Using different chaincode languages](/images/posts/fabric/Lifecycle-languages.png)

一次打包，多次使用：

我们可以打包一次，给链码创建不同的定义，从而运行多个智能合约实例（但是背书策略要有区别）。

![Starting multiple chaincodes](/images/posts/fabric/Lifecycle-multiple.png)



### 1.1.4 比较

做了个表格，把旧的声明周期和新的进行了比较。

|             | 1.x  | 2.0  |
| ----------- | ---- | ---- |
| package     | 有   | 有   |
| install     | 有   | 有   |
| approve     | 无   | 有   |
| commit      | 无   | 有   |
| instantiate | 有   | 无   |
| upgrade     | 有   | 有   |



# 2. private data增强

Fabric 2.0增强了private data，我们不需要创建私有数据集合即可使用私有数据。做了以下增强：

- 私有数据的共享和验证。当私有数据向非原来的集合中的成员共享时，该成员可以通过GetPrivateDataHash() 函数来验证hash是不是和链上保存的hash一致。
- 集合级别的背书策略。我们可以使用背书策略来定义私有数据集合。
- 每个组织都有暗含的私有数据集合。

## 2.1 什么是private data 集合？

在同一个channel中，A组织的数据不想给其他的组织看的数据。从v1.2开始，创造了**private data collections**,我们可以背书，提交和查询私有数据，在不创建一个独立channel的情况下。

private data collections由两部分组成：

- 实际的私有数据。在不同的节点间通过gossip协议来发送。私有数据存储在授权的peer节点上的**sidedb**数据库中，可以通过Chaincode来访问。**order节点无法看到private data**。注意，必须配置锚节点信息，设置CORE_PEER_GOSSIP_EXTERNALENDPOINT变量。
- 私有数据的hash，会写入到区块链网络中，其他人可以进行审计。

<img src="/images/posts/fabric/PrivateDataConcept-2.png" alt="private-data.private-data" style="zoom:33%;" />

当集合中的成员需要把该私有数据向第三方共享时，第三方可以通过比较该数据的hash和链上保存的hash，看是否一致。

还有一些特殊情况，每个组织都可以创建一个私有数据集合，之后可以共享给其他成员。

我们把private data和channel进行一个比较。

- channel：所有的交易和账本都是私密的。
- 私有数据集合：通道中组织的子集共享数据时。直接通过p2p来传播每条具体的交易，而不是区块，order节点无法看到真实的交易。

## 2.2 一个demo

有下面5个角色:

Farmer出售商品，Distributor分销商负责把商品运到海外，Shipper负责在两个角色之间运货，Wholesaler批发商从distributors批发商品，Retailer零售商从shippers和wholesaler购买商品。

场景是：

- Distributor想和Farmer，Shipper共享数据，但是不想让Retailer和wholesaler看到数据；
- Distributor卖给Retailer和wholesaler的价格不同；
- wholesaler和Retailer，Shipper之间也需要共享数据；

为了满足上面的场景，我们不需要建立这么多的channel，可以使用PDC。

- PDC1: **Distributor**, **Farmer** and **Shipper**
- PDC2: **Distributor** and **Wholesaler**
- PDC3: **Wholesaler**, **Retailer** and **Shipper**

![private-data.private-data](/images/posts/fabric/PrivateDataConcept-1.png)

上面场景下，peer节点的账本如下，也称为SideDB。

![private-data.private-data](/images/posts/fabric/PrivateDataConcept-3.png)

## 2.3 private交易流程

1. 客户端发送提案给授权的背书节点，提案中加入transient 字段；
2. 私有数据存储在transient data store（临时的存储在peer节点）；
3. 背书节点发送提案响应到客户端，响应的内容是private data的hash值；
4. 客户端节点把hash值发送给order节点；
5. 在提交阶段，授权的节点将会检查策略，自己是否有权限访问private data，如果有的话，将会检查transient data store 字段，看看是否在背书阶段拿到了private data。没有的话，会从其他节点去拉取。在验证和提交阶段，private data将会被存储到数据库中，同时把transient data store 删除。

## 2.4 私有数据的共享

我们可能会有把私有数据向其他组织或者其他集合共享的需求，接受方需要验证hash：

- 只要满足背书策略(fabric 2.0中，我们可以定义链码级别，键和集合级别的背书策略)，不需要是集合中的成员，即可访问私有数据的键
- 我们可以使用GetPrivateDataHash()来验证hash

在实际中，我们可能会创建大量的私有数据集合，这个不利于我们的维护。更好的情况是每个组织都是一个集合，然后共享就可以了。更好的是我们不必为此进行定义，因为在2.0中默认设置了。

### 2.4.1 私有数据共享模型

下面这个是每个组织一个集合的模型：

- 使用相应的公钥来追踪公共状态的变化：
- 链码访问控制：我们可以在链码实现访问控制，指定哪些客户端可以查看私有数据。
- 共享私有数据：通过hash来确认；
- 和其他集合共享私有数据：
- 可以把私有数据转移到其他的集合。这个时候会删除原来的集合。
- 在交易达成之前，可以使用私有数据进行预请求；
- 保护交易者的隐私

### 2.4.2 私有数据实例

把私有数据模型和链码结合可以发挥出很大的作用，具体如下所示：

- 可以通过处于公共链码状态的UUID密钥来跟踪资产。仅记录资产的所有权，关于资产的其他信息一无所知。
- 链码将要求任何转移请求都必须来自拥有权限的客户，并且密钥受基于状态的认可约束，要求所有者组织和监管机构的同级必须认可任何转移请求。
- 资产的所有者可以看到该资产的所有交易详情，其他的组织只可以看到hash。
- 监管者可以保留私有数据。

具体的交易流如下所示：

1. 资产所有者和买家在线下达成交易价格；
2. 卖家需要证明资产的所有权。既可以线下提供私有数据的细节，也可以提供线上的凭证；
3. 卖家线上验证hash；
4. 买家调用链码记录出价的细节到自己的private data中。监管者可能也需要记录。
5. 卖家调用链码转移资产，需要资产和出价细节的隐私数据，需要卖家，买家，监管者参与，除此之外，还需要满足背书策略；
6. 链码会对上述信息进行验证；
7. 卖家把公开的数据和私有数据的hash提交给order节点，打包成区块；
8. 其他节点将会验证是否满足背书策略，私有数据的状态是否被其他的交易更改；
9. 所有节点会进行记账；
10. 至此交易完成，其他的节点可以查询这笔资产的公开的信息，但无法获取私有信息。

## 2.5 删除私有数据

对于非常敏感的数据，比如政府要求的。我们可以从peer节点上彻底的删除，只留下hash来证明该数据确实存在过。数据删除后，无法从链码进行查询，其他的peer节点也不可查询。

## 2.6 私有数据集合的定义

从fabric 2.0开始，在chaincode定义阶段来进行定义：

- name：集合的名字；
- policy：private data的policy必须比链码的背书策略更加广泛，因为背书节点必须有private data才可以进行背书。比如一个channel里面包含了10个组织，5个组织需要有private data的权限，背书策略可以指定为5个中的三个；
- requiredPeerCount：在背书节点把提案响应返回到客户端之前，最少把private data传递到其他节点的数量。不建议写0，因为这样的话，将会导致private data的丢失。
- maxPeerCount：如果设置为0，在背书阶段，private data将不会传播，在commit阶段，数据才会传播；
- blockToLive：私有数据的存活时间，到期自动删除。设为0表示，永不删除；
- memberOnlyRead：表示只有授权的人可以读。
- memberOnlyWrite：
- endorsementPolicy：

# 3. 外部链码启动器

我们可以使用自己喜欢的方式来构建和启动链码，不必使用docker。

- 解除了对docker daemon的依赖。之前的fabric要求peer节点可以访问到docker daemon，而这在生产环境不一定是现实的。
- 容器的替代品：我们不一定在使用容器了。
- 链码作为外部的服务。之前链码是被peer启动的，现在链码可以作为单独的外部服务。

在Hyperledger Fabric 2.0之前，用于构建和启动链码的过程是peer节点实现的一部分，无法轻松自定义。必须使用特定的语言。这种方法限制了链码的语言，必须依赖容器，chaincode无法作为单独运行的服务。

从2.0开始，我们在peer的core.yaml中，加入了一个externalBuilder的配置来自定义自己的服务。

```yaml
   # List of directories to treat as external builders and launchers for
    # chaincode. The external builder detection processing will iterate over the
    # builders in the order specified below.
    externalBuilders: []
        # - path: /path/to/directory
        #   name: descriptive-builder-name
        #   environmentWhitelist:
        #      - ENVVAR_NAME_TO_PROPAGATE_FROM_PEER
        #      - GOPROXY
```

## 3.1 外部构建模型

fabric的构建器使用了[Heroku Buildpacks](https://devcenter.heroku.com/articles/buildpack-api)。

外部构建和运行期由下面四个部分组成：

- `bin/detect`: 判断是否由我们自定义的模型来运行。
- `bin/build`: 把打包后的链码变为可执行版本。用来构建，编译链码。
- `bin/release` (optional): 提供chaincode的元数据。
- `bin/run` (optional): 运行链码。

下面分别是四个脚本的内容：

#### `detect`：

```shell
#!/bin/bash

CHAINCODE_METADATA_DIR="$2"

# use jq to extract the chaincode type from metadata.json and exit with
# success if the chaincode type is golang
if [ "$(jq -r .type "$CHAINCODE_METADATA_DIR/metadata.json" | tr '[:upper:]' '[:lower:]')" = "golang" ]; then
    exit 0
fi

exit 1
```

#### `build`

```shell
#!/bin/bash

CHAINCODE_SOURCE_DIR="$1"
CHAINCODE_METADATA_DIR="$2"
BUILD_OUTPUT_DIR="$3"

# extract package path from metadata.json
GO_PACKAGE_PATH="$(jq -r .path "$CHAINCODE_METADATA_DIR/metadata.json")"
if [ -f "$CHAINCODE_SOURCE_DIR/src/go.mod" ]; then
    cd "$CHAINCODE_SOURCE_DIR/src"
    go build -v -mod=readonly -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
else
    GO111MODULE=off go build -v  -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
fi

# save statedb index metadata to provide at release
if [ -d "$CHAINCODE_SOURCE_DIR/META-INF" ]; then
    cp -a "$CHAINCODE_SOURCE_DIR/META-INF" "$BUILD_OUTPUT_DIR/"
fi
```

#### `release`

```shell
#!/bin/bash

BUILD_OUTPUT_DIR="$1"
RELEASE_OUTPUT_DIR="$2"

# copy indexes from META-INF/* to the output directory
if [ -d "$BUILD_OUTPUT_DIR/META-INF" ] ; then
   cp -a "$BUILD_OUTPUT_DIR/META-INF/"* "$RELEASE_OUTPUT_DIR/"
fi
```

#### `run`

```shell
BUILD_OUTPUT_DIR="$1"
RUN_METADATA_DIR="$2"

# setup the environment expected by the go chaincode shim
export CORE_CHAINCODE_ID_NAME="$(jq -r .chaincode_id "$RUN_METADATA_DIR/chaincode.json")"
export CORE_PEER_TLS_ENABLED="true"
export CORE_TLS_CLIENT_CERT_FILE="$RUN_METADATA_DIR/client.crt"
export CORE_TLS_CLIENT_KEY_FILE="$RUN_METADATA_DIR/client.key"
export CORE_PEER_TLS_ROOTCERT_FILE="$RUN_METADATA_DIR/root.crt"
export CORE_PEER_LOCALMSPID="$(jq -r .mspid "$RUN_METADATA_DIR/chaincode.json")"

# populate the key and certificate material used by the go chaincode shim
jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_CERT_FILE"
jq -r .client_key  "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_KEY_FILE"
jq -r .root_cert   "$RUN_METADATA_DIR/chaincode.json" > "$CORE_PEER_TLS_ROOTCERT_FILE"
if [ -z "$(jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json")" ]; then
    export CORE_PEER_TLS_ENABLED="false"
fi

# exec the chaincode to replace the script with the chaincode process
exec "$BUILD_OUTPUT_DIR/chaincode" -peer.address="$(jq -r .peer_address "$ARTIFACTS/chaincode.json")"
```

## 3.2 配置外部的构建器和运行器

上面说了，这个是在core.yaml中配置的，一个demo如下所示：

```yaml
chaincode:
  externalBuilders:
  - name: my-golang-builder
    path: /builders/golang
    environmentWhitelist:
    - GOPROXY
    - GONOPROXY
    - GOSUMDB
    - GONOSUMDB
  - name: noop-builder
    path: /builders/binary
```



# 4. CouchDB中使用了状态数据库缓存来提高性能

- 使用外部CouchDB状态数据库时，背书和验证阶段的读取延迟历来是性能瓶颈。
- fabric 2.0中，每个peer都进行了缓存，在core.yaml中的cacheSize来进行配置。

# 5. 基于Alpine来打包docker镜像

从 v2.0 开始，Hyperledger Fabric Docker 镜像将使用 Alpine Linux 作为基础镜像，这是一个面向安全的轻量级 Linux 发行版。这意味着 Docker 镜像现在要小得多，提供更快的下载和启动时间，以及占用主机系统上更少的磁盘空间。Alpine Linux 的设计从一开始就考虑到了安全性，Alpine 发行版的最小化特性大大降低了安全漏洞的风险。

# 6. Release notes

## 新特性

**FAB-11237:**去中心化的智能合约管理

新的应用程序模式：

- **FAB-10889: Implicit org-specific collections**
- **FAB-15066: Endorsement policies for collections**
- **FAB-13581: memberOnlyWrite collection configuration option**
- **FAB-13527: GetPrivateDataHash chaincode API**
- **FAB-12043: Option to include private data in block events**

**FAB-103: State database cache for CouchDB**

## 重要变化

- **FAB-5177: The ccenv build image no longer includes the shim**
- **FAB-15366: Logger removed from chaincode shim**

- **FAB-16213: The go chaincode entities extension has been removed**

- **FAB-12075: Client Identity (CID) library has moved**
- **FAB-14720: Support for CAR chaincode package format removed**
- **FAB-15285: Support for invoking system chaincodes from user chaincodes
  has been removed.**
- **FAB-15390: Support for peer's Admin service has been removed.**
- **FAB-16303: GetHistoryForKey returns results from newest to oldest**
- **FAB-16722: The 'provisional' genesis method of generating the system channel
  for orderers has been removed.**
- **FAB-16477 and FAB-17116: New configuration for orderer genesismethod and genesisfile**
- **FAB-15343: System Chaincode Plugins have been removed.**
- **FAB-11096: Docker images with Alpine Linux**
- **FAB-11096: Bash not available in Docker images with Alpine Linux**
  - 使用sh或者ash
- **FAB-15499: Ledger data format upgrade**
- **FAB-16866: Chaincode built upon installation on peer**
- **FAB-15837: Orderer FileLedger location moved if specified with relative path**
- **FAB-14271: Policies must be specified in configtx.yaml**
- **FAB-17000: Warn when certificates are about to expire**
- **FAB-16987: Go version has been updated to 1.13.4.**

# 废除

- **FAB-15754: The 'Solo' consensus type is deprecated.**
- **FAB-16408: The 'Kafka' consensus type is deprecated.**
- **FAB-7559: Support for specifying orderer endpoints at the global level
  in channel configuration is deprecated.**
- **FAB-17428: Support for configtxgen flag `--outputAnchorPeersUpdate` is deprecated.**
