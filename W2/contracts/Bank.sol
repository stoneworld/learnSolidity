//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
W2_1作业：
* 编写⼀个Bank合约：
* 通过 Metamask 向Bank合约转账ETH
* 在Bank合约记录每个地址转账⾦额
* 编写 Bank合约withdraw(), 实现提取出所有的 ETH
 */
contract Bank {
    address public owner; // owner of the bank
    bool internal locked;

    mapping(address => uint) public balances; // balances of each account
    event Deposit(address indexed from, uint value);

    constructor() payable { // constructor
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable { // receive 函数可能只有 2300 gas 可以用（当使用 send 或者 transfer 转账的时候），可能就没有安全的足够的 gas 来调用 receive 函数
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public noReentrant {
        require(balances[msg.sender] > 0, "No ether to withdraw"); // require 函数，如果 balances[msg.sender] <= 0，则抛出异常
        require(address(this).balance >= balances[msg.sender], "you ether was stolen"); // require 函数，如果 address(this).balance <= balances[msg.sender]，则抛出异常
        (bool success ,) = msg.sender.call{value: balances[msg.sender]}("");
        balances[msg.sender] = 0;
        require(success, "user failed to withdraw");
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function withdrawAll() payable external { // 合约 owner 提取所有的ETH
        uint amount = address(this).balance;
        require(amount > 0, "No ether to withdraw");
        (bool success ,) = owner.call{value: amount}("");
        require(success, "Owner failed to withdraw");
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    fallback() external payable {}
    
}