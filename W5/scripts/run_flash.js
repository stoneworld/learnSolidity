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
  let aAmount = ethers.utils.parseUnits("100", 18);
  let flashAddress = "0x5dC58F3D7de05748D83e6a4b8cAd0ac48C6EE9Fc";

  let flash = await ethers.getContractAt("FlashSwap", flashAddress, second);

  let tx = await flash.execArbitrage("0xdD333a05aF349D939Cd2Ca4295053C02C578e067", "0x57cc8842F4e1212d971D7e485D37d383Af569c51", 0, aAmount, {gasLimit: 10000000 });

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
