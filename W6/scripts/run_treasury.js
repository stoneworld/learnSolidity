let { ethers, network } = require("hardhat");

const multiSigWalletAddr = require(`../deployments/${network.name}/multiSigWallet.json`)
const TreasuryAddr = require(`../deployments/${network.name}/treasury.json`)


async function main() {
    // await run('compile');

    const [owner, second] = await hre.ethers.getSigners();

    provider = ethers.getDefaultProvider(network.name);
    balance = await provider.getBalance(TreasuryAddr.address);

    console.log(balance);

    let multiSigWalletAddress = multiSigWalletAddr.address;

    let multiSigWallet = await ethers.getContractAt("MultiSigWallet", multiSigWalletAddress, owner);

    
    const iface = new ethers.utils.Interface([
        "function withdraw(uint assetAmount, address userAddress)",
    ])

    let aAmount = ethers.utils.parseEther("0.01");
    const data = iface.encodeFunctionData("withdraw", [
        aAmount, "0x657295B6af08C35e6972459ce2203540356C9216"
    ])

    /**
     *  address _to,
        uint _value,
        bytes memory _data
     */
    let result1 = await multiSigWallet.submitTransaction(TreasuryAddr.address, ethers.utils.parseEther("0"), data, { gasLimit: 1000000 });

    console.log(result1)
    await result1.wait();

    console.log("done");

    let tx = await multiSigWallet.confirmTransaction(0, { gasLimit: 1000000 });

    await tx.wait();

    let tx3 = await multiSigWallet.executeTransaction(0, { gasLimit: 1000000 });

    console.log(tx3);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
