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

V2添加流动性:
https://rinkeby.etherscan.io/tx/0xac161f631956d7a90864eebbdfe28b7ed88eda6a9fae5a73835877f10e135c5c

V3添加流动性:
<img src=./assets/WechatIMG276.png width=50% />

计算公式如下：
当前兑换率是按照 V2 的价格进行输入：

AToken 总提供量是 200000：

那么根据公式可以计算出流动性是：200000 = (1 / √当前价格（2） - 1 / √最高兑换率（3.9746）) * L

然后 BToken = L * Δ√p = L (√当前价格（2） - √最低兑换率（0.4966）)

添加流动性的地址：https://rinkeby.etherscan.io/tx/0xb1ea3d111533d7f03505f1e022d8a38e20c2f69b352ac773a6c724bca5098628

流动性添加完毕后发现存在套利空间。
执行的 hash：https://rinkeby.etherscan.io/tx/0x59b9d52ce5e94d42597acb2d31110276fbd7286dd3fcca90204b39dd5ade5761

<img src=./assets/WechatIMG278.png width=50% />


合约详细代码见 FlashSwap.sol，下面列出来重要的两个方法，执行的 js 脚本在 run_flash.js 中。
```
// 这里借 A 还 B amount0 != 0 amount1 是 A 的数量
function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override{ 
   // 这里 amount0 对应的 BToken, amount1 对应的是 AToken
   address token0;
   address token1;
   address[] memory path = new address[](2);
   {
      token0 = IUniswapV2Pair(msg.sender).token0(); // BToken
      token1 = IUniswapV2Pair(msg.sender).token1(); // AToken
      assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1)); // ensure that msg.sender is actually a V2 pair
      assert(amount0 == 0 || amount1 == 0); // this strategy is unidirectional
      path[0] = amount0 == 0 ? token0 : token1;
      path[1] = amount0 == 0 ? token1 : token0;
   }
   // path 对应的是 [AToken, BToken]

   // 先授权V3合约允许调用自身的 A token
   uint256 amountReceived = swapExactInputSingle(token1, token0, amount1);

   uint256 amountRequired = UniswapV2Library.getAmountsIn(factory, amount1, path)[0]; // 这里是需要还给池子中 B 的数量，其实简单理解是获取到指定数量的 A 需要多少 B.

   require(IERC20(token0).balanceOf(address(this)) > amountRequired, 'amount is yes'); // return tokens to V2 pair

   require(amountRequired > 0, 'need > 0'); // fail if we didn't get enough B back to repay our flash loan

   require(amountReceived > amountRequired, 'not enough'); // fail if we didn't get enough B back to repay our flash loan

   assert(IERC20(token0).transfer(msg.sender, amountRequired)); // 合约再转给 pair 池子
   assert(IERC20(token0).transfer(tx.origin, amountReceived - amountRequired)); // 剩下的装给自己
}

function swapExactInputSingle(address token0, address token1, uint256 amountIn) public returns (uint256 amountOut) { //调用 univ3 的兑换方法。
   TransferHelper.safeApprove(token0, address(V3Router), amountIn);

   // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
   // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
   ISwapRouter.ExactInputSingleParams memory params =
      ISwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: 10000,
            recipient: address(this), // 兑换的转给合约
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
      });

   // The call to `exactInputSingle` executes the swap.
   amountOut = ISwapRouter(V3Router).exactInputSingle(params);
}


```

### <span id="jump2">第二节课作业</span>

W5_2作业
* 在一笔交易中完成（模拟闪电贷交易）
   * 在 AAVE 中借款 token A
   * 使用 token A 在 Uniswap V2 中交易兑换 token B，然后在 Uniswap V3 token B 兑换为 token A
   * token A 还款给 AAVE

aave 闪电贷：
1. 不需要抵押
2. executeOperation 方法操作完成前需要保证钱足够然后将要还的部分授权给 POOL，剩下的部分留给自己，合约本身不需要处理还款逻辑，授权后 POOL 合约会完成后续流程。

SimpleFlashLoanReceiver.sol:

为了方便这里 token A 用 dai，因为 aave 测试网还行不能借自定义的token，所以需要在 univ2 和 v3需要加 dai 和 B token 的池子。

<img src=./assets/WechatIMG561.png width=50% />

<img src=./assets/WechatIMG562.png width=50% />

从图中可以看到存在套利空间。

```
// sol 主要代码

function execSimpleLoan(address _token, uint256 _amount, bytes calldata params) public {
   POOL.flashLoanSimple(address(this), _token, _amount, params, 0);
}

function executeOperation(
   address asset,
   uint256 amount,
   uint256 premium,
   address initiator, // initiator: msg.sender 调用闪电贷的用户
   bytes memory params // params
) public override returns (bool) {
   require(msg.sender == address(POOL), "Only allow aave POOL to call"); // 这里的 msg.sender 指的是 aave POOL
   (address Btoken, address userAddress) = abi.decode(params, (address, address));

   // asset -> Btoken in uniswap v2
   
   // 首先授权借的 dai 给 V2 router

   IERC20(asset).approve(SWAP_V2_ROUTER, amount);

   // 在 V2 router 中交易兑换 Btoken
   address[] memory path1 = new address[](2); // 1:1
   path1[0] = asset;
   path1[1] = Btoken;

   uint[] memory amounts1 = IV2SwapRouter(SWAP_V2_ROUTER).swapExactTokensForTokens(amount,uint256(0),path1,address(this),block.timestamp+20);
   // amounts1[1] 即为兑换的 Btoken 数量

   // Btoken -> asset in uniswap v3 // 1:3

   // 首先授权兑换后的的 Btoken 给 V3 router

   IERC20(Btoken).approve(SWAP_V3_ROUTER, amounts1[1]);
   uint256 amountOut = swapExactInputSingle(Btoken, asset, amounts1[1], amount); // 最少 amount 个

   //check the contract has the specified balance
   require(amount <= IERC20(asset).balanceOf(address(this)), 'Invalid balance for the contract');

   uint256 amountToReturn = amount.add(premium);

   IERC20(asset).approve(address(POOL), amountToReturn); // 授权 POOL 承担还款费用
   IERC20(asset).transfer(userAddress, amountOut.sub(amountToReturn)); // 剩下的转给 userAddress

   return true;
}

function swapExactInputSingle(address token0, address token1, uint256 amountIn, uint256 amountOutMinimum) public returns (uint256 amountOut) {
   // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
   // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
   ISwapRouter.ExactInputSingleParams memory params =
      ISwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            fee: 3000,
            recipient: address(this), // 兑换的转给合约
            deadline: block.timestamp + 20,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
      });

   // The call to `exactInputSingle` executes the swap.
   amountOut = ISwapRouter(SWAP_V3_ROUTER).exactInputSingle(params);
}

async function main() {
    const [owner, second] = await hre.ethers.getSigners();
    let flashAddress = "0xc38b9bbC1AE01a341718DAC5eb9a62B7006996A8"; // 合约地址
    let aAmount = ethers.utils.parseUnits("100", 18);
    let simpleFlashLoanReceiver = await ethers.getContractAt("SimpleFlashLoanReceiver", flashAddress, second);
    data = ethers.utils.defaultAbiCoder.encode(["address"], ["0xF85599564b418586C4039A6fdbCD9b4C1F9E198b"]);

    let tx = await simpleFlashLoanReceiver.execSimpleLoan("0x2ec4c6fcdbf5f9beeceb1b51848fc2db1f3a26af", aAmount, data, { gasLimit: 10000000 });

    console.log(tx);
}

```

最后执行的结果：https://rinkeby.etherscan.io/tx/0xa52fd046d35b014390fd945fc9cb1af66f311170e609bcc42ca756d1f0fd13bc

<img src=./assets/WechatIMG563.png width=50% />
