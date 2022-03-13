const { ethers, network } = require("hardhat");

const NFTAddr = require(`../deployments/${network.name}/DevNFT.json`)


//event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

async function parseTransferEvent(event) {

    const TransferEvent = new ethers.utils.Interface(["event Transfer(address indexed from,address indexed to,uint256 indexed tokenId)"]);
    let decodedData = TransferEvent.parseLog(event);
    console.log("from:" + decodedData.args.from);
    console.log("to:" + decodedData.args.to);
    console.log("value:" + decodedData.args.tokenId);
}

async function main() {


    let [owner, second] = await ethers.getSigners();
    let devNFT = await ethers.getContractAt("DevNFT", NFTAddr.address, owner);

    let filter = devNFT.filters.Transfer(null, owner.address)


    ethers.provider.on(filter, (event) => {

        console.log(event)

        parseTransferEvent(event);
    })
}

main()