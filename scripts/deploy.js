const hre = require("hardhat");


async function deployProxied(contractName) {
  console.log("Deploying", contractName)
  const InventoryManagerFactory = await hre.ethers.getContractFactory(contractName);
  let invMan = await InventoryManagerFactory.deploy();
  console.log(invMan.address)

  console.log("Deploying Proxy")
  const ProxyFac = await hre.ethers.getContractFactory("Proxy");
  let pp = await ProxyFac.deploy(invMan.address);
  console.log(pp.address)

  let a = await hre.ethers.getContractAt(contractName, pp.address);
  return a;
}

async function main() {
  await hre.run("compile");
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});