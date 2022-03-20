let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');
const MyTokenAddr = require(`../deployments/${network.name}/Token.json`)



async function main() {
    // await run('compile');
    let [owner, second] = await ethers.getSigners();
    let aAmount = ethers.utils.parseUnits("100000", 18);

    const SushiToken = await hre.ethers.getContractFactory("SushiToken");
    const sushiToken = await SushiToken.deploy();
    await sushiToken.deployed();
    console.log("SushiToken deployed to:", sushiToken.address);
    await writeAddr(sushiToken.address, "SushiToken", hre.network.name);

    const MasterChef = await hre.ethers.getContractFactory("MasterChef");
    const masterChef = await MasterChef.deploy(sushiToken.address, owner.address, ethers.utils.parseEther('50'), 0, 10000000);
    await masterChef.deployed();
    console.log("MasterChef deployed to:", masterChef.address);
    await writeAddr(masterChef.address, "masterChef", hre.network.name);
    sushiToken.transferOwnership(masterChef.address);

    await masterChef.add(aAmount, MyTokenAddr.address, true);

    const poolInfo = await masterChef.poolInfo(0);
    console.log("MasterChef poolInfo:", poolInfo.lpToken);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
