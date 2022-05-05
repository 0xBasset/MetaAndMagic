const { ethers } = require("hardhat");
const hre = require("hardhat");

const deployedContracts = require("../contracts.json")

async function deployProxied(contractName) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy();
  console.log(impl.address)

  await new Promise(resolve => setTimeout(resolve, 5000));

  console.log("Deploying Proxy")
  const ProxyFac = await hre.ethers.getContractFactory("Proxy");
  let proxy = await ProxyFac.deploy(impl.address);
  console.log(proxy.address)

  await new Promise(resolve => setTimeout(resolve, 5000));


  let a = await hre.ethers.getContractAt(contractName, proxy.address);
  return a;
}

async function deploy(contractName) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy();
  console.log(impl.address)
  await new Promise(resolve => setTimeout(resolve, 5000));
  return impl
}

async function updateProxy(contractName, address) {
    console.log("Deploying", contractName)
    const ImplFact = await hre.ethers.getContractFactory(contractName);
    let impl = await ImplFact.deploy();
    console.log(impl.address)
    await impl.deployed();

    console.log("Updating Impl")
    let a = await hre.ethers.getContractAt("Proxy", address);

    await a.setImplementation(impl.address);

    let im = await hre.ethers.getContractAt(contractName, address);
    return im
}

async function getContract(contractName, address) {
    let a = await hre.ethers.getContractAt(contractName,address)
    return a;
}

async function main() {
  await hre.run("compile");

  let contracts = deployedContracts[hre.network.name]

  // renderer = await hre.ethers.getContractAt("MetaAndMagicRenderer", "0xfEb68fEE8c7F4c5f166df09925b88F0d7DF0Cc49"); 
  
  // renderer.setDeck(1, contracts["HeroesDeck"]);
  // renderer.setDeck(2, contracts["ItemsDeck"]);

  let sale = await updateProxy("MetaAndMagicSale", "0x197c53FFE5BAC8452440e2656f71246B9Dba5565");
  await sale.initialize("0xFcB6B373A0109071129Ae31974644Ebb9b47aC05","0x2c7985027940e506145642d92CBc9e269de16252");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
