const hre = require("hardhat");

const contracts = require("../contracts.json")

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

  // Deploy Stats address
  let statsHero  = await deploy("HeroStats");
  let statsAtk   = await deploy("AttackItemsStats");
  let statsDef   = await deploy("DefenseItemsStats");
  let statsSpell = await deploy("SpellItemsStats");
  let statsBuff  = await deploy("BuffItemsStats");
  let statsBoss  = await deploy("BossDropsStats");
  let lens       = await deploy("MetaAndMagicLens");

  let metaRenderer;

  let heroes = await deployProxied("HeroesMock");
  let items  = await deployProxied("ItemsMock");
  let meta   = await deployProxied("MetaAndMagic");

  // Config everything
  console.log("Setting up")
  await meta.initialize(heroes.address, items.address);
  await meta.setUpOracle(contracts[hre.network.name].vrfCoord,contracts[hre.network.name].keyHash,contracts[hre.network.name].subId)
  console.log("Done meta")

 await new Promise(resolve => setTimeout(resolve, 1000));

  await heroes.initialize(statsHero.address,statsHero.address) // todo replace with actual renderer
  await heroes.setUpOracle(contracts[hre.network.name].vrfCoord,contracts[hre.network.name].keyHash,contracts[hre.network.name].subId);
  await heroes.setAuth(meta.address, true);
  console.log("Done heroes")

  await new Promise(resolve => setTimeout(resolve, 1000));

  await items.initialize(statsAtk.address, statsDef.address, statsSpell.address, statsBuff.address, statsBoss.address, statsBoss.address); // todo replace with renderer
  await items.setUpOracle(contracts[hre.network.name].vrfCoord,contracts[hre.network.name].keyHash,contracts[hre.network.name].subId);
  await items.setAuth(items.address, true);
  console.log("Done items")

  await lens.initialize(heroes.address, items.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
