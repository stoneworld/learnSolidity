// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy

    const [owner, second] = await hre.ethers.getSigners();
    let flashAddress = "0x7FdBa4B377Bc6dcAb923345C6f5066fA69559188";
    let aAmount = ethers.utils.parseUnits("100", 18);

    let simpleFlashLoanReceiver = await ethers.getContractAt("SimpleFlashLoanReceiver", flashAddress, second);
    data = ethers.utils.defaultAbiCoder.encode(["address", "address"], ["0xF85599564b418586C4039A6fdbCD9b4C1F9E198b", "0x657295B6af08C35e6972459ce2203540356C9216"]);

    let tx = await simpleFlashLoanReceiver.execSimpleLoan("0x2ec4c6fcdbf5f9beeceb1b51848fc2db1f3a26af", aAmount, data, { gasLimit: 10000000 });

    console.log(tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
