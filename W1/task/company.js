// npx hardhat help company
// npx hardhat counter --address 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 --network dev

task("company", "Prints current counter vaule")
    .addParam("address", "The counter's address")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.address;
        let [owner, two] = await ethers.getSigners();

        let company = await ethers.getContractAt("Company", contractAddr, two);

        let userAdd = await company.getTotalUser();

        let currValue = await company.getTotalUser();

        console.log("current counter vaule:" + currValue);
    });

module.exports = {};