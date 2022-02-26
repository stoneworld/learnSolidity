//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Company {
    int public totalUser; // 状态变量（函数之外声明的变量）默认为“存储”类型，永久写入区块链。 函数内的storage表示对状态变量的引用
    
    constructor(int _totalUser) { // 构造函数初始化 totalUser = _totalUser
        console.logInt(_totalUser);
        totalUser = _totalUser;
    }

    function incTotalUser() public {
        totalUser += 1;
    }

    function getTotalUser() public view returns (int) { // 定义可以公开访问的 getTotalUser 函数
        return totalUser;
    }
}
