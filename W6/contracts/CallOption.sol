// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


/**
W6_1作业
* 设计一个看涨期权Token:
   * 创建期权Token 时，确认标的的价格与行权日期；
   * 发行方法（项目方角色）：根据转入的标的（ETH）发行期权Token；
   * （可选）：可以用期权Token 与 USDT 以一个较低的价格创建交易对，模拟用户购买期权。
   * 行权方法（用户角色）：在到期日当天，可通过指定的价格兑换出标的资产，并销毁期权Token
   * 过期销毁（项目方角色）：销毁所有期权Token 赎回标的。
 */

contract CallOption is ERC20, Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint public constant during = 1 days; //  1 day
    uint strikePrice; // 执行价格
    uint expiration; // 行权日期
    address daiAddress; // dai地址
    uint amount; // 期权行权数量
    

    constructor(address dai, uint price) ERC20("CallOptionToken", "COPT") {
        daiAddress = dai;
        strikePrice = price;
        expiration = block.timestamp + 20 seconds; // 为了测试这里设置为20秒
        amount = 1;
    }

    // 发行期权Token 根据转入的标的（ETH）发行期权Token；
    function mint() public payable onlyOwner {
        _mint(msg.sender, (msg.value).div(amount));
    }

    // 行权，在到期日当天，可通过指定的价格兑换出标的资产，并销毁期权Token
    function settlement(uint _amount) public {
        require(block.timestamp >= expiration && block.timestamp < expiration + during, "Expiration time has not arrived");
        _burn(msg.sender, _amount); // 销毁用户的token
        // 兑换出标的资产
        uint256 assetAmount = amount.mul(_amount);
        // 需要的资产数量
        uint256 daiAmount = assetAmount.mul(strikePrice);
        // 需要将该数量的资产授权给合约
        IERC20(daiAddress).safeTransferFrom(msg.sender, address(this), daiAmount);
        safeTransferETH(msg.sender, assetAmount);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function burnAll() external onlyOwner {
        require(block.timestamp >= expiration + during, "not end");
        uint256 daiAmount = IERC20(daiAddress).balanceOf(address(this));
        IERC20(daiAddress).safeTransfer(msg.sender, daiAmount);
        selfdestruct(payable(msg.sender));
  }
}