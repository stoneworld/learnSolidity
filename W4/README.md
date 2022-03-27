## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)
3. [课程总结记录](#jump3)


### <span id="jump1">第一节课作业</span>

W4_1作业
* 部署自己的 ERC20 合约 MyToken
* 编写合约 MyTokenMarket 实现：
   * AddLiquidity():函数内部调用 UniswapV2Router 添加 MyToken 与 ETH 的流动性
   * buyToken()：用户可调用该函数实现购买 MyToken

首先分别部署了：
1. factory Contract:0x3fC86Dd09b21231bbbEd6D9E6A579f14908b0800
https://rinkeby.etherscan.io/tx/0xf865193e7d6af191370d3eaa6b22186bae39311cdc5904dda0eb6a1251944f5f

2. WETH Contract:0xB94D569c6f10264540d726758DC2788E2e70E689
https://rinkeby.etherscan.io/tx/0xed2000c62d80d7598cd56c9f037851f688cf63115848f9848f924647ca6ef749

3. Router Contract:0xF2CA21a365C02a8Bb6E7A7337B8C1246997b71D7
https://rinkeby.etherscan.io/tx/0x1d6e68f98f2bf3fce9c62602e63b861ac84af8996b8f0dca247e78b66e5bdcda

添加流动性代码如下:
```
function AddLiquidity(uint tokenAmount) public payable {
    IERC20(myToken).safeTransferFrom(msg.sender, address(this),tokenAmount); // 转账之前需要授权
    IERC20(myToken).safeApprove(router, tokenAmount);

    // (uint amountToken, uint amountETH, uint liquidity) = 
    IUniswapV2Router01(router).addLiquidityETH{value: msg.value}(myToken, tokenAmount, 0, 0, msg.sender, block.timestamp);
    // IUniswapV2Router01.addLiquidityETH 其实这里后面已经处理过了多余的 ETH 返回给用户的操作，如下：
    // if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);

}
```
注意调用添加流动性的时候需要给予足够的 gas 费用。
执行结果如图：

<img src=./assets/WX20220320-102323@2x.png width=50% />

https://rinkeby.etherscan.io/tx/0xb281b6d6cc085a4d8fe6bee48709a28d4f8f04e9d98eb221f78337f77ad96ded


使用ETH购买 Token 代码如下:
```
function buyToken(uint minTokenAmount) public payable { // 使用 ETH 购买 token 需要设置为 payable
    address[] memory path = new address[](2);
    path[0] = weth;
    path[1] = myToken;

    IUniswapV2Router01(router).swapExactETHForTokens{value : msg.value}(minTokenAmount, path, msg.sender, block.timestamp);
}

```

执行结果如图：

<img src=./assets/WX20220320-102352@2x.png width=50% />

https://rinkeby.etherscan.io/tx/0x41fb31e6a08a5eac3b285ef0b81c4005b055f57739aa2dbc1b8d302c9fd8c712



### <span id="jump2">第二节课作业</span>

W4_2作业
* 在上一次作业的基础上：
   * 完成代币兑换后，直接质押 MasterChef
   * withdraw():从 MasterChef 提取 Token 方法

部署 MasterChef 合约后需要将 sushiToken.transferOwnership(masterChef.address); 因为在 MasterChef 内部调用有 onlyOwner 的限制。
部署 MasterChef 的 js 代码在 scripts 目录下。

```
function buyToken(uint minTokenAmount) public payable {
    address[] memory path = new address[](2);
    path[0] = weth;
    path[1] = myToken;

    IUniswapV2Router01(router).swapExactETHForTokens{value : msg.value}(minTokenAmount, path, address(this), block.timestamp);
    uint amountToken = IERC20(myToken).balanceOf(address(this));
    console.log("amountToken:", amountToken);
    IERC20(myToken).approve(masterChef, amountToken); // 授权 masterChef 操作
    MasterChef(masterChef).deposit(0, amountToken);
    depositAmounts[msg.sender] += amountToken; // 存储用户的质押的押金数量
}

function withdrawToken() external {
    uint amountToken = depositAmounts[msg.sender];
    MasterChef(masterChef).withdraw(0, amountToken); // 提取到 Market 合约中
    IERC20(myToken).safeTransfer(msg.sender, amountToken); // 转给用户
    // sushi 奖励给用户
    uint sushiTokenAmount = IERC20(MasterChef(masterChef).sushi()).balanceOf(address(this)); // withdraw 的时候会把奖励打给 MyTokenMarket 合约，所以要把奖励打给用户
    console.log("sushiTokenAmount:", sushiTokenAmount);
    IERC20(MasterChef(masterChef).sushi()).safeTransfer(msg.sender, sushiTokenAmount); // 这里存在问题，这里将 address.this 的奖励全部给了提取的用户。其实应该算出当前用户应该的奖励。
}

```







