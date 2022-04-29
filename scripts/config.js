const hre = require("hardhat");

const deployedContracts = require("../contracts.json")

async function getContract(contractName, address) {
    let a = await hre.ethers.getContractAt(contractName,address)
    return a;
}

async function main() {
  await hre.run("compile");

  let contracts = deployedContracts[hre.network.name]

  nonce = 116;
  
  let metaRenderer = contracts["MetaAndMagicRenderer"];
  let heroes = await getContract("Heroes", contracts["Heroes"]);
  let items  = await getContract("Items", contracts["Items"]);
  let meta = await getContract("MetaAndMagic", contracts["MetaAndMagic"]);
  let sale  = await getContract("MetaAndMagicSale", contracts["MetaAndMagicSale"]);
  let lens  = await getContract("MetaAndMagicLens", contracts["MetaAndMagicLens"]);

  // Config everything
  console.log("Setting up")
  await meta.initialize(heroes.address, items.address, {nonce: nonce});
  nonce++
  await meta.setUpOracle(contracts.vrfCoord,contracts.keyHash,contracts.subId, {nonce: nonce})
  nonce++
  console.log("Done meta")

  await heroes.initialize(contracts["HeroStats"], metaRenderer, {nonce:nonce})
  nonce++  
  await heroes.setUpOracle(contracts.vrfCoord,contracts.keyHash,contracts.subId, {nonce:nonce});
  nonce++
  await heroes.setAuth(meta.address, true, {nonce:nonce});
  nonce++
  await heroes.setAuth(sale.address, true, {nonce:nonce});
  nonce++
  console.log("Done heroes")

  await items.initialize(contracts["AttackItemsStats"], contracts["DefenseItemsStats"], contracts["SpellItemsStats"], contracts["BuffItemsStats"], contracts["BossDropsStats"], metaRenderer, {nonce: nonce});
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
