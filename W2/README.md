## 目录
1. [第一节课作业](#jump1)
2. [第二节课作业](#jump2)

### <span id="jump1">第一节课作业</span>

* 编写⼀个Bank合约：
* 通过 Metamask 向Bank合约转账ETH
* 在Bank合约记录每个地址转账⾦额
* 编写 Bank合约withdraw(), 实现提取出所有的 ETH


首先是定义一个合约如下：

```
contract Bank {
    address public owner; // 定义了合约的拥有者

    mapping(address => uint) public balances; // balances of each account 定义了一个 map 记录每个地址转账的金额总数

    constructor() payable { // constructor 设置 payable 才能在合约部署的时候带上 ETH 
        owner = msg.sender;
    }
}
```

其次定义了一个 receive 函数，因为用户可能存在直接向合约转账的方式。

```
receive() external payable { //  因为 receive 函数可能只有 2300 gas 可以用（当使用 send 或者 transfer 转账的时候），因此函数中不能存在过多的逻辑
    balances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
}

fallback() external payable {}

```

用户还可以选择通过调用合约方法的方式来转账，因此定义了一个 deposit 函数如下，其函数体内容是和receive一致的：

```
function deposit() public payable {
    balances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
}
```

用户可以提取自己捐赠的 ETH，因此定义了一个 withdraw 函数，可以看出我在这里用到了一个 modifier noReentrant，其实最开始并没有加上这个，但后续发现存在重入的问题，同时需要定义一个外部不可修改和读取的 locked 状态变量。

```

bool internal locked; 

function withdraw() public noReentrant {
    require(balances[msg.sender] > 0, "No ether to withdraw"); // require 函数，如果 balances[msg.sender] <= 0，则抛出异常
    require(address(this).balance >= balances[msg.sender], "you ether was stolen"); // require 函数，如果 address(this).balance <= balances[msg.sender]，则抛出异常
    (bool success ,) = msg.sender.call{value: balances[msg.sender]}("");
    require(success, "user failed to withdraw");
    balances[msg.sender] = 0;
}

modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
}

```


最后定义了一个提取全部余额的函数，如下：

```

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

```

最后通过 Metamask 进行转账的交易hash地址如下：https://rinkeby.etherscan.io/tx/0x59644839ca3baeae91968506de8cc776da65f97687370a0e828d2ad667690cfd

退款的交易执行hash地址如下：https://rinkeby.etherscan.io/tx/0x1f5db3352c1e69f1c4ec3154f0662c68e153ea3ef6022353020d5ccc59582be1

整体合约完成见 [Bank.sol](./contracts/Bank.sol)

### <span id="jump2">第二节课作业</span>

* 编写合约Score，⽤于记录学⽣（地址）分数：
   * 仅有⽼师（⽤modifier权限控制）可以添加和修改学⽣分数
   * 分数不可以⼤于 100； 
* 编写合约 Teacher 作为⽼师，通过 IScore 接⼝调⽤修改学⽣分数。

首先定义一个合约 Score 如下, 这个Score合约更像是一个班级的合约，包含了学生的分数，以及班级的老师，班级的老师在班级创建之初就确定了。

```
contract Score {
    mapping(address => uint) public studentScores; // 学生分数

    address public teacher; // ⽼师地址

    constructor(address _teacher) {
        teacher = _teacher;
    }
}

```

其次定义一个修改分数的函数如下，定义了两个 `modifier` 分别限制只能 Teacher address 才能修改，以及修改的分数不能超过100分。

```

function changeUserScore(address _addr, uint _score) public onlyLessThan100(_score) onlyTeacher {
    studentScores[_addr] = _score;
}

modifier onlyTeacher {
    require(msg.sender == teacher);
    _;
}

modifier onlyLessThan100(uint score) {
    require(score <= 100, "Score must be less than or equal to 100");
    _;
}

```

因为这里是需要 Teacher 通过 IScore 接口的方式修改分数这里定义了一个接口，以及 Teacher 合约如下：

```
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
```

整体合约完成见 [Score.sol](./contracts/Score.sol)
