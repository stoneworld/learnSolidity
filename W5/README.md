## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)
3. [课程总结记录](#jump3)


### <span id="jump1">第一节课作业</span>

W5_1作业
* 以太坊测试网上部署两个自己的ERC20合约MyToken，分别在Uniswap V2、V3(网页上)添加流动性
* 作业：编写合约执行闪电贷（参考V2的ExampleFlashSwap）：
   * uniswapV2Call中，用收到的 TokenA 在 Uniswap V3 的 SwapRouter 兑换为 TokenB 还回到 uniswapV2 Pair 中。

首先部署了两个自己的 ERC20 合约，余额打到了部署账号钱包中，因为是测试闪电贷，所以添加流动性的时候要存在套利的空间。
这里 V2 的添加流动性 AToken:BToken = 100000:100000
V2添加流动性:https://rinkeby.etherscan.io/tx/0xac161f631956d7a90864eebbdfe28b7ed88eda6a9fae5a73835877f10e135c5c
V3添加流动性:
<img src=./assets/WechatIMG276.png width=50% />

计算公式如下：
当前兑换率是按照 V2 的价格进行输入：

AToken 总提供量是 200000：

那么根据公式可以计算出流动性是：200000 = (1 / √当前价格（2） - 1 / √最高兑换率（3.9746）) * L

然后 BToken = L * Δ√p = L (√当前价格（2） - √最低兑换率（0.4966）)

添加流动性的地址：https://rinkeby.etherscan.io/tx/0xb1ea3d111533d7f03505f1e022d8a38e20c2f69b352ac773a6c724bca5098628

流动性添加完毕后发现存在套利空间：

合约代码见 FlashSwap.sol

### <span id="jump2">第二节课作业</span>

W5_2作业
* 在一笔交易中完成（模拟闪电贷交易）
   * 在 AAVE 中借款 token A
   * 使用 token A 在 Uniswap V2 中交易兑换 token B，然后在 Uniswap V3 token B 兑换为 token A
   * token A 还款给 AAVE

TODO