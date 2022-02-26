const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Company", function () {
  it("Should return the new company totalUser once it's changed", async function () {
    const Company = await ethers.getContractFactory("Company");
    const company = await Company.deploy(0);
    await company.deployed();

    expect(await company.getTotalUser()).to.equal(0);

    const incTotalUserTx = await company.incTotalUser();

    // wait until the transaction is mined
    await incTotalUserTx.wait();

    expect(await company.getTotalUser()).to.equal(1);
  });
});
