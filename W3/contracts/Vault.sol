//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    mapping (address => mapping (address => uint256)) deposits;
    // 编写deposit ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额
    function deposit(address _token, uint256 _amount) public payable {
        // 存款⾦额记录
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "deposite failed");
        deposits[_token][msg.sender] += _amount;
    }

    function withdraw(address _token, uint _amount) public {
        // 提取⾦额记录
        require(IERC20(_token).transferFrom(address(this), msg.sender, _amount), "withdraw failed");
        deposits[_token][msg.sender] -= _amount;
    }
}
