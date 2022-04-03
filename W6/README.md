## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)
3. [课程总结记录](#jump3)


### <span id="jump1">第一节课作业</span>
W6_1作业
* 设计一个看涨期权Token:
   * 创建期权Token 时，确认标的的价格与行权日期；
   * 发行方法（项目方角色）：根据转入的标的（ETH）发行期权Token；
   * （可选）：可以用期权Token 与 USDT 以一个较低的价格创建交易对，模拟用户购买期权。
   * 行权方法（用户角色）：在到期日当天，可通过指定的价格兑换出标的资产，并销毁期权Token
   * 过期销毁（项目方角色）：销毁所有期权Token 赎回标的。


首先理解下看涨期权：是在看涨期权的买卖双方之间以固定价格交换证券的合同。看涨期权的买方有权（但没有义务）在特定时间以一定的价格从期权的卖方购买约定数量的特定商品或金融工具。

整体合约代码完成见 [CallOption.sol](./contracts/CallOption.sol)

这里并没有在 Uni 构造一个交易池子，只是项目方自己 mint，又作为用户进行了行权操作。

```
const erc20Dai = await ethers.getContractAt(daiInfo.abi, daiAddress, owner);

let result = await erc20Dai.approve(CallOptionAddr.address, aAmount); // 行权之前记得进行授权

await result.wait();

let bAmount = ethers.utils.parseUnits("0.1", 18);

let result1 = await callOption.settlement(bAmount, { gasLimit: 1000000 });
```

行权hash地址：

<img src=./assets/WechatIMG294.png width=50% />

https://rinkeby.etherscan.io/tx/0xd67de5387ea1684fbd9e67466a4365b6b0469f2f0bf14a9ff0c40ccd30245918


### <span id="jump2">第二节课作业</span>

W6_2作业（可选）
* 实现⼀个通过 DAO 管理资⾦的Treasury：
   * 管理员可以从Treasury合约中提取资⾦withdraw（）
   * 治理Gov合约作为管理员
   * 通过发起提案从Treasury合约资⾦

