## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)


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

首先这里的治理合约是一个多签合约：

整体多签合约代码完成见 [MultiSigWallet.sol](./contracts/MultiSigWallet.sol)，代码注释有对多签代码的理解。

Treasury 合约利用了 AccessControl 进行权限控制，这里只有多签合约作为管理员调用 withdraw 方法。

```
contract Treasury is AccessControl {
    bytes32 public constant GOV_ROLE = keccak256("GOV_ROLE");
    
    constructor(address _governor) {
        _setRoleAdmin(GOV_ROLE, GOV_ROLE);
        _setupRole(GOV_ROLE, _governor);
    }

    // 提取指定数量的 ETH 到指定地址
    function withdraw(uint assetAmount, address userAddress) public payable onlyRole(GOV_ROLE){
        require(address(this).balance >= assetAmount, "you ether not enough");
        safeTransferETH(userAddress, assetAmount);
    }

    receive() external payable {}

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

```

而后利用 MultiSigWallet 进行提案发起：

```
const iface = new ethers.utils.Interface([
   "function withdraw(uint assetAmount, address userAddress)",
])

let aAmount = ethers.utils.parseEther("0.01");
const data = iface.encodeFunctionData("withdraw", [
   aAmount, "0x657295B6af08C35e6972459ce2203540356C9216"
])

/**
*  address _to,
   uint _value,
   bytes memory _data
*/
let result1 = await multiSigWallet.submitTransaction(TreasuryAddr.address, ethers.utils.parseEther("0"), data, { gasLimit: 1000000 });

```

经过多签钱包签名 confirmTransaction 到达设置的签名个数后进行提案的执行 executeTransaction。

执行的结果如下：https://rinkeby.etherscan.io/tx/0x05da9e5a87c4b77cc889097400b0738bf1b648bbb4b8b2f1b64c3a1469da1c90

<img src=./assets/WX20220404-214329@2x.png width=50% />

