// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance); //存款事件
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    ); // 提交一笔交易事件
    event ConfirmTransaction(address indexed owner, uint indexed txIndex); // 确认一笔交易事件
    event RevokeConfirmation(address indexed owner, uint indexed txIndex); // 撤销一笔交易事件
    event ExecuteTransaction(address indexed owner, uint indexed txIndex); // 执行一笔交易事件

    address[] public owners; // 多签的所有者
    mapping(address => bool) public isOwner; // owner mapping
    uint public numConfirmationsRequired; // 多签执行所需要的确认数

    struct Transaction {
        address to; // 交易的地址
        uint value; // 附加的 ETH 数量
        bytes data; // abi.encodeWithSignature("func(arg)", args);
        bool executed; // 是否已经执行
        uint numConfirmations; // 确认数
    }

    // mapping from tx index => owner => bool 针对某笔交易的某个 owner 是否确认
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions; // 交易的list

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }
    // 初始化owner和确认数
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // 提交一笔交易，把交易列表 push 到 transactions
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length; // 从 0 开始

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    // 确认一笔交易：交易的确认需要是 owner,交易需要存在且未执行状态且该owner未确认过
    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex]; // 获取交易 引用
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex); // 事件 谁确认了某笔交易
    }
    // 执行交易，需要确认数大于等于 numConfirmationsRequired，且未执行过该交易
    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;
        console.log("address:", transaction.to);
        console.log("value:", transaction.value);
    
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // 撤销一笔交易的确认，需要是 owner,交易需要存在且未执行状态且该owner已确认过
    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    // 获取多签的 owners
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    // 获取总交易数
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    // 获取某一笔交易信息
    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}

// contract TestContract {
//     uint public i;

//     function callMe(uint j) public {
//         i += j;
//     }

//     function getData() public pure returns (bytes memory) {
//         return abi.encodeWithSignature("callMe(uint256)", 123);
//     }
// }