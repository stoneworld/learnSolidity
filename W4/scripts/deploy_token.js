let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');

async function main() {
    // await run('compile');
    let Token = await ethers.getContractFactory("Token");
    let aAmount = ethers.utils.parseUnits("100000", 18);
    let atoken = await Token.deploy(
        "AToken",
        "AToken",
        aAmount);

    await atoken.deployed();
    console.log("AToken:" + atoken.address);
    console.log(1);
    await writeAddr(atoken.address, "Token", network.name)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
