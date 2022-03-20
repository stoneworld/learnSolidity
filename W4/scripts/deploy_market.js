let { ethers } = require("hardhat");
let { writeAddr } = require('./artifact_log.js');
const MyTokenAddr = require(`../deployments/${network.name}/Token.json`)
const masterChefAddr = require(`../deployments/${network.name}/masterChef.json`)
const SushiTokenAddr = require(`../deployments/${network.name}/SushiToken.json`)


async function main() {
    // await run('compile');
    let aAmount = ethers.utils.parseUnits("10000", 18);

    let MyTokenMarket = await ethers.getContractFactory("MyTokenMarket");

    let routerAddr = "0xF2CA21a365C02a8Bb6E7A7337B8C1246997b71D7";
    let wethAddr = "0xB94D569c6f10264540d726758DC2788E2e70E689";
    console.log(masterChefAddr.address);
    console.log(MyTokenAddr.address);

    let market = await MyTokenMarket.deploy(
        MyTokenAddr.address,
        routerAddr,
        wethAddr,
        masterChefAddr.address,
    );

    await market.deployed();
    console.log("market:" + market.address);

    [owner, second] = await ethers.getSigners();
    let atoken = await ethers.getContractAt("Token", MyTokenAddr.address, owner);
    let sushiToken = await ethers.getContractAt("SushiToken", SushiTokenAddr.address, owner);

    await atoken.approve(market.address, ethers.constants.MaxUint256);

    let ethAmount = ethers.utils.parseUnits("0.1", 18);
    console.log("添加流动性");
    let result = await market.AddLiquidity(aAmount, { value: ethAmount, gasLimit: 8000000 });
    console.log(result);
    await result.wait();

    let b = await atoken.balanceOf(owner.address);
    console.log("持有token:" + ethers.utils.formatUnits(b, 18));

    let buyEthAmount = ethers.utils.parseUnits("0.05", 18);
    out = await market.buyToken("0", { value: buyEthAmount, gasLimit: 8000000 });

    b = await atoken.balanceOf(owner.address);
    console.log("购买到:" + ethers.utils.formatUnits(b, 18));

    await market.withdrawToken({gasLimit: 10000000 });

    b = await atoken.balanceOf(owner.address);

    console.log("购买到:" + ethers.utils.formatUnits(b, 18));

    c = await sushiToken.balanceOf(owner.address);
    console.log("质押获得:" + ethers.utils.formatUnits(c, 18));

    d = await sushiToken.balanceOf(market.address);
    console.log("质押获得:" + ethers.utils.formatUnits(d, 18));

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
