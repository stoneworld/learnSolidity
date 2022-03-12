// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");


async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const Token = await hre.ethers.getContractFactory("Token");
    const token = await Token.deploy();

    await token.deployed();

    console.log("Token deployed to:", token.address);

    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("owner:" + owner.address);

    await token.addCanMintAddress(addr1.address); // 增加可以增发的地址
    console.log(owner.address);
    await token.connect(addr1).claimToken(owner.address, ethers.utils.parseUnits("3000")); // 增发功能

    await token.connect(addr1).claimToken(addr2.address, ethers.utils.parseUnits("3000")); // 增发功能

    const balance = await token.balanceOf(addr2.address);

    console.log("balance:" + balance); 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
