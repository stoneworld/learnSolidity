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

    mapping(address => uint) public balances; // balances of each account

    event Transfer(address indexed from, address indexed to, uint value);

    constructor(address _owner) { // constructor
        owner = _owner;
    }

    receive() external payable { // receive ether 这里可能存在问题 因为 receive 函数可能只有 2300 gas 可以用（当使用 send 或者 transfer 转账的时候），可能就没有安全的足够的 gas 来调用 receive 函数
        balances[msg.sender] += msg.value;
        emit Transfer(msg.sender, msg.sender, msg.value); // 这个其实可有可无，因为这个不是 erc20 代币的转账，交易日志本身就会记录。
    }

    function withdraw() payable external {
        require(balances[msg.sender] > 0, "No ether to withdraw"); // require 函数，如果 balances[msg.sender] <= 0，则抛出异常
        require(address(this).balance > balances[msg.sender], "you ether was stolen"); // require 函数，如果 address(this).balance <= balances[msg.sender]，则抛出异常
        balances[msg.sender] -= msg.value;
        payable(msg.sender).transfer(balances[msg.sender]);
    }

    function withdrawAll() payable external { // 合约 owner 提取所有的ETH
        require(msg.sender == owner, "Only owner can withdrawAll");
        require(address(this).balance > 0, "No ether to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
    
}