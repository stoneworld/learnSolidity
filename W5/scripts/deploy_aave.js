let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');

async function main() {
    // await run('compile');
    const [owner, second] = await ethers.getSigners();
    let SimpleFlashLoanReceiver = await ethers.getContractFactory("SimpleFlashLoanReceiver");
    let simpleFlashLoanReceiver = await SimpleFlashLoanReceiver.deploy(
        "0xA55125A90d75a95EC00130E8E8C197dB5641Eb19",
    );

    await simpleFlashLoanReceiver.deployed();
    console.log("FlashSwap:" + simpleFlashLoanReceiver.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
