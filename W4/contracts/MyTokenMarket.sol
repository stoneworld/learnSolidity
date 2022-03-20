//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";
import "./MasterChef.sol";




interface IMasterChef {
    function deposit(uint256 pid, uint256 amount) external;
    function withdraw(uint256 pid, uint256 amount) external;
    function sushi() external;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
}

contract MyTokenMarket {
    using SafeERC20 for IERC20;

    address public myToken;
    address public router;
    address public weth;
    address public masterChef;

    mapping (address => uint256) public depositAmounts;

    constructor(address _token, address _router, address _weth, address _masterChef) {
        myToken = _token;
        router = _router;
        weth = _weth;
        masterChef = _masterChef;
    }

    // 添加流动性
    function AddLiquidity(uint tokenAmount) public payable {
        IERC20(myToken).safeTransferFrom(msg.sender, address(this),tokenAmount);
        IERC20(myToken).safeApprove(router, tokenAmount);
        console.log("router address:", router);
        console.log("masterChef address:", masterChef);
        console.log("sender address:", msg.sender);

        // ingnore slippage
        // (uint amountToken, uint amountETH, uint liquidity) = 
        IUniswapV2Router01(router).addLiquidityETH{value: msg.value}(myToken, tokenAmount, 0, 0, msg.sender, block.timestamp);

    }

    // 用 ETH 购买 Token
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
        IERC20(MasterChef(masterChef).sushi()).safeTransfer(msg.sender, sushiTokenAmount);
    }

}