//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

/**
W3_2作业
* 发行一个 ERC721 Token
   * 使用 ether.js 解析 ERC721 转账事件(加分项：记录到数据库中，可方便查询用户持有的所有NFT)
   * (或)使用 TheGraph 解析 ERC721 转账事件
 */

 contract DevNFT is ERC721URIStorage, ReentrancyGuard {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //token总数

    constructor() ERC721 ("DevNFT", "DevNFT") {
        console.log("This is my DEV NFT contract. Woah!");
    }

    function MyDevNFTMint() public nonReentrant{
        uint newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, "Test");

        _tokenIds.increment();
    }

 }