const { ethers, network } = require("hardhat");
async function main() {
    let [owner, two] = await ethers.getSigners();
    let company = await ethers.getContractAt("Company",
        `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`,
        two);

    await company.incTotalUser();

    let newValue = await company.getTotalUser();

    console.log("newValue:" + newValue)

}


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });