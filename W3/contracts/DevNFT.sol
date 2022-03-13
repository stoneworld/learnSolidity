//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/**
W3_2作业
* 发行一个 ERC721 Token
   * 使用 ether.js 解析 ERC721 转账事件(加分项：记录到数据库中，可方便查询用户持有的所有NFT)
   * (或)使用 TheGraph 解析 ERC721 转账事件
 */

 contract DevNFT is ERC721URIStorage,Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //token总数

    constructor() ERC721 ("DevNFT", "DevNFT") Ownable() {
        console.log("This is my DEV NFT contract. Woah!");
    }

    function MyDevNFTMint() public {
        uint newTokenId = _tokenIds.current();
        require(newTokenId < 8888, "Token ID invalid");

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, "https://prod-metadata.s3.amazonaws.com/tokens/721.json"); // 这里写死

        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);

    }

 }