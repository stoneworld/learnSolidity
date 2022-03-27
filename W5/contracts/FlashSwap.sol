//SPDX-License-Identifier: Unlicense


/**
* 作业：编写合约执行闪电贷（参考V2的ExampleFlashSwap）：
   * uniswapV2Call中，用收到的 TokenA 在 Uniswap V3 的 SwapRouter 兑换为 TokenB 还回到 uniswapV2 Pair 中。
 */

pragma solidity ^0.8.0;

import './IERC20.sol';
import './UniswapV2Library.sol';

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}


contract FlashSwap is IUniswapV2Callee {

    address immutable factory;
    address immutable V3Router;
    address owner;

    receive() external payable {}

    // v2 _factory 0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f, v3 _v3Router:0xE592427A0AEce92De3Edee1F18E0157C05861564
    constructor(address _factory, address _v3Router) {
        factory = _factory;
        V3Router = _v3Router;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function execArbitrage(address token0, address token1, uint amount0, uint amount1) onlyOwner public {
        address pairAddress = UniswapV2Library.pairFor(factory, token0, token1);
        require(pairAddress != address(0), 'There is no such pool');
        IUniswapV2Pair(pairAddress).swap(amount0, amount1, address(this), "0x");
    }

    function getPairAddress(address token0, address token1) onlyOwner public view returns(address pairAddress, address atoken0, address btoken1) {
        pairAddress = UniswapV2Library.pairFor(factory, token0, token1);
        atoken0 = IUniswapV2Pair(pairAddress).token0(); // BToken
        btoken1 = IUniswapV2Pair(pairAddress).token1(); // AToken
    }

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

        uint256 amountRequired = UniswapV2Library.getAmountsIn(factory, amount1, path)[0]; // 这里是需要还给池子中 B 的数量

        require(IERC20(token0).balanceOf(address(this)) > amountRequired, 'amount is yes'); // return tokens to V2 pair

        require(amountRequired > 0, 'need > 0'); // fail if we didn't get enough B back to repay our flash loan

        require(amountReceived > amountRequired, 'not enough'); // fail if we didn't get enough B back to repay our flash loan

        assert(IERC20(token0).transfer(msg.sender, amountRequired)); // return tokens to V2 pair
        assert(IERC20(token0).transfer(tx.origin, amountReceived - amountRequired)); // keep the rest! (tokens)
    }

    function swapExactInputSingle(address token0, address token1, uint256 amountIn) public returns (uint256 amountOut) {
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
}


