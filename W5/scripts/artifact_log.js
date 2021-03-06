const fs = require('fs');
const path = require('path');
const util = require('util');

const writeFile = util.promisify(fs.writeFile);

async function writeAddr(addr, name, network) {
    const deployments = {};
    deployments["address"] = addr;
    deployments["contractName"] = name;
    await writeLog(deployments, name, network);
}

async function writeAbiAddr(artifacts, addr, name, network) {
    console.log(`../deployments/${network}/${name}.json`)
    const deployments = {};
    deployments["address"] = addr;
    deployments["contractName"] = artifacts.contractName;

    var dir = './deployments/abi';

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    var dir = './deployments/dev';

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }


    const deploymentDevPath = path.resolve(__dirname, `../deployments/dev/${network}-${deployments["contractName"]}.json`);
    await writeFile(deploymentDevPath, JSON.stringify(deployments, null, 2));

    const abis = {};
    abis["contractName"] = artifacts.contractName;
    abis["abi"] = artifacts.abi;
    const deploymentAbiPath = path.resolve(__dirname, `../deployments/abi/${abis["contractName"]}.json`);


    await writeFile(deploymentAbiPath, JSON.stringify(abis, null, 2));
}

// for Truffle deployment
async function writeAbis(artifacts, name, network) {
    const deployments = {};
    deployments["address"] = artifacts.address;
    deployments["contractName"] = artifacts.contractName;
    await writeLog(deployments, name, network);

    const abis = {};
    abis["contractName"] = artifacts.contractName;
    abis["abi"] = artifacts.abi;

    const deploymentPath = path.resolve(__dirname, `../deployments/abi/${abis["contractName"]}.json`);
    await writeFile(deploymentPath, JSON.stringify(abis, null, 2));
}

/**
 * 记录合约发布地址
 * @param {*} deployments json
 * @param {*} name 类型
 * @param {*} network 网络
 */
async function writeLog(deployments, name, network) {
    const deploymentPath = path.resolve(__dirname, `../deployments/${network}/${name}.json`);
    await writeFile(deploymentPath, JSON.stringify(deployments, null, 2));
    console.log(`Exported deployments into ${deploymentPath}`);
}

module.exports = {
    writeLog,
    writeAbis,
    writeAbiAddr,
    writeAddr
}