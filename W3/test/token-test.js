const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token", function () {
    it("Should return the new Token once it's changed", async function () {
        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy();
        await token.deployed();
        const [owner, addr1, addr2] = await ethers.getSigners();
        console.log("owner:" + owner.address);

        await token.addCanMintAddress(addr1.address); // 增加可以增发的地址

        expect(await token.canMintAddresses(addr1.address)).to.equal(true); // 测试是否该地址可以增发

        await token.connect(addr1).claimToken(addr2.address, 3000); // 测试增发功能

        expect(await token.balanceOf(addr2.address)).to.equal(3000); // 测试增发后的余额

    });
});
