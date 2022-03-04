// TODO 作业
1. 默认 transfer  方法 gas 默认为 2300 所以如果向合约转账使用这个的话，receive 方法存在其它业务逻辑会存在转账失败的情况，
但 address.call{value:1 ether}("") 方法不会,但 call 会切换上下文，如果存在调用其它合约的调用的话，但 delegatecall 不会切换上下文。


bytes memory methodData = abi.encodeWithSignature("transfer(uint256)", _n)

address.call(methodData)
address.delegatecall(methodData)

临时数组一定要定长。

uint160(uint(hash))


W2_1作业：
* 编写⼀个Bank合约：
* 通过 Metamask 向Bank合约转账ETH
* 在Bank合约记录每个地址转账⾦额
* 编写 Bank合约withdraw(), 实现提取出所有的 ETH