const { ethers, network } = require("hardhat");
// const delay = require('./delay');

const NFTAddr = require(`../deployments/${network.name}/DevNFT.json`)


async function main() {

    let [owner, second] = await ethers.getSigners();

    let devNFT = await ethers.getContractAt("DevNFT",
        NFTAddr.address,
        owner);

    await devNFT.MyDevNFTMint();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });