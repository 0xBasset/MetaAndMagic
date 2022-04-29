const hre = require("hardhat");

const deployedContracts = require("../contracts.json")

async function deployProxied(contractName, nonce) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy({nonce: nonce});
  nonce++
  console.log(impl.address)

  console.log("Deploying Proxy")
  const ProxyFac = await hre.ethers.getContractFactory("Proxy");
  let proxy = await ProxyFac.deploy(impl.address, {nonce: nonce});
  console.log(proxy.address)

  await proxy.deployed();

  let a = await hre.ethers.getContractAt(contractName, proxy.address);
  return a;
}

async function deploy(contractName, nonce) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy({nonce: nonce});
  console.log(impl.address)
  return impl
}

async function main() {
  await hre.run("compile");

  // Deploy Stats address
  let statsHero  = await deploy("HeroStats");
  let statsAtk   = await deploy("AttackItemsStats");
  let statsDef   = await deploy("DefenseItemsStats");
  let statsSpell = await deploy("SpellItemsStats");
  let statsBuff  = await deploy("BuffItemsStats", nonce);
  let statsBoss  = await deploy("BossDropsStats", nonce);

  let contracts = deployedContracts[hre.network.name]

  nonce = 111;
  
  let metaRenderer = "0xfEb68fEE8c7F4c5f166df09925b88F0d7DF0Cc49";
  
  let lens   = await deployProxied("MetaAndMagicLens", nonce);
  nonce += 2
  let heroes = await deployProxied("Heroes", nonce);
  nonce += 2
  let items  = await deployProxied("Items", nonce);
  nonce += 2
  let meta   = await deployProxied("MetaAndMagic", nonce);
  nonce += 2
  let sale   = await deployProxied("MetaAndMagicSale", nonce);
  nonce += 2

  // Config everything
  console.log("Setting up")
  await meta.initialize(heroes.address, items.address, {nonce: nonce});
  nonce++
  await meta.setUpOracle(contracts.vrfCoord,contracts.keyHash,contracts.subId, {nonce: nonce})
  nonce++
  console.log("Done meta")

  await heroes.initialize(statsHero.address, metaRenderer, {nonce:nonce})
  nonce++  
  await heroes.setUpOracle(contracts.vrfCoord,contracts.keyHash,contracts.subId, {nonce:nonce});
  nonce++
  await heroes.setAuth(meta.address, true, {nonce:nonce});
  nonce++
  await heroes.setAuth(sale.address, true, {nonce:nonce});
  nonce++
  console.log("Done heroes")

  await items.initialize(statsAtk.address, statsDef.address, statsSpell.address,statsBuff.address, statsBoss.address, metaRenderer, {nonce: nonce});
  nonce++
  await items.setUpOracle(contracts.vrfCoord,contracts.keyHash,contracts.subId, {nonce: nonce});
  nonce++
  await items.setAuth(meta.address, true, {nonce: nonce});
  nonce++
  await items.setAuth(sale.address, true, {nonce: nonce});
  nonce++
  console.log("Done items"),

  await sale.initialize(heroes.address, items.address,{nonce:nonce});
  nonce++
  await lens.initialize(meta.address, heroes.address, items.address,{nonce:nonce});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
