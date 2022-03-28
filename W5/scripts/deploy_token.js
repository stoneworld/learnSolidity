let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');

async function main() {
    // await run('compile');
    const [owner, second] = await ethers.getSigners();
    let Token = await ethers.getContractFactory("Token", second);
    let aAmount = ethers.utils.parseUnits("10000000", 18);
    let atoken = await Token.deploy(
        "AToken",
        "AToken",
        aAmount);

    await atoken.deployed();
    console.log("AToken:" + atoken.address);

    let btoken = await Token.deploy(
        "BToken",
        "BToken",
        aAmount);

    await btoken.deployed();
    console.log("BToken:" + btoken.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
