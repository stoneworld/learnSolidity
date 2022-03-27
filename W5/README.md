x:10 y:100
const data = web3.eth.abi.encodeFunctionCall({
    name: 'anotherfunction',
    type: 'function',
    inputs: [{
        type: 'uint256',
        name: ''
    },{
        type: 'address',
        name: ''
    }]
}, ['123', '0x0000000000000000000000000000000000000045']);
