let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');

async function main() {
    const [owner, second] = await ethers.getSigners();
    let MultiSigWallet = await ethers.getContractFactory("MultiSigWallet", owner);
    let multiSigWallet = await MultiSigWallet.deploy(["0x657295B6af08C35e6972459ce2203540356C9216", "0xD1D92F86922c70dC5c24f1614aCD31013272c836", "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"], 1);

    await multiSigWallet.deployed();
    console.log("MultiSigWallet:" + multiSigWallet.address);

    await writeAddr(multiSigWallet.address, "multiSigWallet", hre.network.name);

    let Treasury = await ethers.getContractFactory("Treasury", owner);

    let treasury = await Treasury.deploy(multiSigWallet.address);

    await treasury.deployed();
    console.log("Treasury:" + treasury.address);
    
    await writeAddr(treasury.address, "Treasury", hre.network.name);
    const tx = await owner.sendTransaction({
        to: treasury.address,
        value: ethers.utils.parseEther("0.01")
    });
    await tx.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
