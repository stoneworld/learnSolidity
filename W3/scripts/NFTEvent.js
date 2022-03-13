const { ethers, network } = require("hardhat");

const NFTAddr = require(`../deployments/${network.name}/DevNFT.json`)
var db = require('./mysql/mysql.js');


//event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

async function parseTransferEvent(event) {

    const TransferEvent = new ethers.utils.Interface(["event Transfer(address indexed from,address indexed to,uint256 indexed tokenId)"]);
    let decodedData = TransferEvent.parseLog(event);
    var addSql = 'INSERT INTO tb_devnft_mint_history(token_id,from_address,to_address) VALUES(?,?,?)';
    var addSqlParams = [decodedData.args.tokenId.toString(),decodedData.args.from, decodedData.args.to];
    db.query(addSql, addSqlParams, function (result, fields) {
        console.log('添加成功');
    });
}

async function main() {


    let [owner, second] = await ethers.getSigners();
    let devNFT = await ethers.getContractAt("DevNFT", NFTAddr.address, owner);

    let filter = devNFT.filters.Transfer(null, owner.address)

    ethers.provider.on(filter, (event) => {
        parseTransferEvent(event);
    })
}

main()