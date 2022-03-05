//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
* 编写合约Score，⽤于记录学⽣（地址）分数：
   * 仅有⽼师（⽤modifier权限控制）可以添加和修改学⽣分数
   * 分数不可以⼤于 100； 
* 编写合约 Teacher 作为⽼师，通过 IScore 接⼝调⽤修改学⽣分数。

 */
contract Score {
    mapping(address => uint) public studentScores; // 学生分数

    address public teacher; // ⽼师地址

    constructor(address _teacher) {
        teacher = _teacher;
    }

    modifier onlyTeacher {
        require(msg.sender == teacher);
        _;
    }

    modifier onlyLessThan100(uint score) {
        require(score <= 100, "Score must be less than or equal to 100");
        _;
    }

    function changeUserScore(address _addr, uint _score) public onlyLessThan100(_score) onlyTeacher {
        studentScores[_addr] = _score;
    }
}

interface IScore {
    function changeUserScore(address _addr, uint _score) external;
}

contract Teacher {

    address public teacher; // ⽼师地址

    constructor() {
        teacher = msg.sender;
    }

    modifier onlyTeacher {
        require(msg.sender == teacher);
        _;
    }

    function changeUserScore(address _score, address _userAddr, uint _studentScore) public onlyTeacher {
        IScore(_score).changeUserScore(_userAddr, _studentScore);
    }
}