// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./UniswapV2Library.sol";
import "./ISwapRouter.sol";
import "./interfaces/IPoolAddressesProvider.sol";
import "./FlashLoanSimpleReceiverBase.sol";

import "./IERC20.sol";


/**
   * 在 AAVE 中借款 token A
   * 使用 token A 在 Uniswap V2 中交易兑换 token B，然后在 Uniswap V3 token B 兑换为 token A
   * token A 还款给 AAVE
 */
contract SimpleFlashLoanReceiver is FlashLoanSimpleReceiverBase {
    using SafeMath for uint256;

    //_addressProvider 0xA55125A90d75a95EC00130E8E8C197dB5641Eb19
    constructor(IPoolAddressesProvider _addressProvider) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
    }

    address public constant SWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant SWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

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

}