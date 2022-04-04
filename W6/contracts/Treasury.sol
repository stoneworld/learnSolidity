//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
* 实现⼀个通过 DAO 管理资⾦的Treasury：
   * 管理员可以从Treasury合约中提取资⾦withdraw（）
   * 治理Gov合约作为管理员
   * 通过发起提案从Treasury合约资⾦
 */
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