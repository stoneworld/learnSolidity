const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Company", function () {
  it("Should return the new company totalUser once it's changed", async function () {
    const Company = await ethers.getContractFactory("Company");
    const company = await Company.deploy(0);
    await company.deployed();
    const [owner, addr1] = await ethers.getSigners();
    await company.connect(addr1).incTotalUser(); // 使用不同的用户签名、测试
    expect(await company.connect(addr1).getTotalUser()).to.equal(1);

    const incTotalUserTx = await company.incTotalUser();

    // wait until the transaction is mined
    
    await incTotalUserTx.wait();

    expect(await company.getTotalUser()).to.equal(2);
  });
});
