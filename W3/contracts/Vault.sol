//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Vault {
    using SafeERC20 for IERC20;

    mapping (address => mapping (address => uint256)) public deposits;
    // 编写deposit ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额
    function deposit(address _token, uint256 _amount) public {
        // 存款⾦额记录
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        deposits[_token][msg.sender] += _amount;
    }

    function withdraw(address _token, uint _amount) public {
        // 提取⾦额记录
        require(deposits[_token][msg.sender] >= _amount, "not enough balance");
        IERC20(_token).safeTransfer(msg.sender, _amount);
        deposits[_token][msg.sender] -= _amount;
    }
}
