const ethers = require('ethers');
const Addr = require(`../artifacts/contracts/Company.sol/Company.json`)


async function main() {
    // Connect to the network 
    let provider = new ethers.providers.JsonRpcProvider(); // 本地 provider 其实 hardhat 就已经帮我们自动处理了

    console.log(provider)

    // 地址来自上面部署的合约
    let contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

    // 使用Provider 连接合约，将只有对合约的可读权限
    let contract = new ethers.Contract(contractAddress, Addr.abi, provider);

    console.log(contract);

    // 从私钥获取一个签名器 Signer
    let privateKey = '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
    let wallet = new ethers.Wallet(privateKey, provider);

    provider.getTransactionCount(wallet.address).then((transactionCount) => {
        console.log("发送交易总数: " + transactionCount);
    });

    // 使用签名器创建一个新的合约实例，它允许使用可更新状态的方法
    let contractWithSigner = contract.connect(wallet);

    console.log(contractWithSigner);
    // ... 或 ...
    // let contractWithSigner = new Contract(contractAddress, abi, wallet)

    // 设置一个新值，返回交易
    let tx = await contractWithSigner.incTotalUser();

    console.log(tx.hash);
    // "0xaf0068dcf728afa5accd02172867627da4e6f946dfb8174a7be31f01b11d5364"

    // 操作还没完成，需要等待挖矿
    await tx.wait();

    // 再次调用合约的 getValue()
    let newValue = await contract.getTotalUser();

    provider.on('block', (blockNumber) => {
        console.log('New Block: ' + blockNumber);
    });
    
    console.log(newValue);

}


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
