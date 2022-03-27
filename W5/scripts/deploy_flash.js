let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');

async function main() {
    // await run('compile');
    const [owner, second] = await ethers.getSigners();
    let FlashSwap = await ethers.getContractFactory("FlashSwap", second);
    let flashSwap = await FlashSwap.deploy(
        "0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f",
        "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    );

    await flashSwap.deployed();
    console.log("FlashSwap:" + flashSwap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
