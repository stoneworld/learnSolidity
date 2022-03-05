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

// TODO