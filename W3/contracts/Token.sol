//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


/**
W3_1作业
* 发⾏⼀个 ERC20 Token： 
   * 可动态增发（起始发⾏量是 0） 
   * 通过 ethers.js. 调⽤合约进⾏转账
* 编写⼀个Vault 合约：
   * 编写deposite ⽅法，实现 ERC20 存⼊ Vault，并记录每个⽤户存款⾦额 ， ⽤从前端调⽤（Approve，transferFrom） 
   * 编写 withdraw ⽅法，提取⽤户⾃⼰的存款 （前端调⽤）
   * 前端显示⽤户存款⾦额
    */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public constant maxTokenNumber = 1000000000;
    mapping(address => bool) public userIsClaim; // 用户是否已经mint过。
    uint256 public constant perUserMaxClaimNumber = 100000;

    constructor() ERC20("Developer", "Dev") {}

    function claim(address _to, uint256 _amount) public {
        require(msg.sender == tx.origin, "Invalid EOA address"); // 不允许合约进行增发，简单的处理方式
        require(userIsClaim[msg.sender] == false, "You have already claimed"); // 不允许重复增发
        require(_amount <= perUserMaxClaimNumber, "You can only claim 100000 tokens at a time"); // 单用户不允许增发超过100000个
        uint256 _totalSupply = totalSupply();
        require((_amount + _totalSupply) <= maxTokenNumber, "Amount exceeds max token number");
        _mint(_to, _amount);
        userIsClaim[_to] = true;
    }
}