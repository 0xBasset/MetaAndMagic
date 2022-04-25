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

async function main() {
  await hre.run("compile");

  let contracts = deployedContracts[hre.network.name]

  let heroes = await deployProxied("HeroesMock");
  let items  = await deployProxied("ItemsMock");
  // let sale   = await deployProxied("MetaAndMagicSale");

  // Config everything
  console.log("Setting up")

  await heroes.initialize(contracts["HeroStats"],contracts["MetaAndMagicRenderer"]) // todo replace with actual renderer
  // await heroes.setAuth(sale.address, true);
  await heroes.setEntropy("14939537241763278366545887256611457859659144253696778057464814769031071232383")
  console.log("Done heroes")

  await items.initialize(contracts["AttackItemsStats"], contracts["DefenseItemsStats"],contracts["SpellItemsStats"] , contracts["BuffItemsStats"], contracts["BossDropsStats"], contracts["MetaAndMagicRenderer"]); // todo replace with renderer
  // await items.setAuth(sale.address, true);
  await items.setEntropy("14939537241763278366545887256611457859659144253696778057464814769031071232383")
  console.log("Done items")

  // await sale.initialize(heroes.address, items.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
