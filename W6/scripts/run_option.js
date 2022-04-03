let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');
const CallOptionAddr = require(`../deployments/${network.name}/CallOption.json`)
const daiInfo = require(`./dai.json`)

async function main() {
    // await run('compile');

    const [owner, second] = await hre.ethers.getSigners();
    let optionAddress = CallOptionAddr.address;
    let aAmount = ethers.utils.parseUnits("100", 18);

    let callOption = await ethers.getContractAt("CallOption", optionAddress, owner);

    // This can be an address or an ENS name
    const daiAddress = daiInfo.address;

    const erc20Dai = await ethers.getContractAt(daiInfo.abi, daiAddress, owner);

    let daiAmount = await erc20Dai.balanceOf(owner.address);

    console.log(daiAmount);
    
    let result = await erc20Dai.approve(CallOptionAddr.address, aAmount);

    await result.wait();

    let bAmount = ethers.utils.parseUnits("0.1", 18);

    let result1 = await callOption.settlement(bAmount, { gasLimit: 1000000 });

    console.log(result1);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
