const hre = require("hardhat");

async function deployProxied(contractName) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy();
  console.log(impl.address)

  console.log("Deploying Proxy")
  const ProxyFac = await hre.ethers.getContractFactory("Proxy");
  let proxy = await ProxyFac.deploy(impl.address);
  console.log(proxy.address)

  await proxy.deployed();

  let a = await hre.ethers.getContractAt(contractName, proxy.address);
  return a;
}

async function deploy(contractName) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy();
  console.log(impl.address)
  await impl.deployed();
  return impl
}

async function main() {
  await hre.run("compile");

  const inventoryContracts = ["HeroLevel","HeroClass","HeroRankWarrior","HeroRankMarksman","HeroRankAssassin","HeroRankMonk","HeroRankMage","HeroRankZombie", "HeroRankGod", "HeroRankOracle","HeroRarity","HeroPet", "HeroItem","HeroOne","ItemAttackLevel", "ItemAttackKind","ItemAttackMaterial","ItemAttackRarity","ItemAttackQuality","ItemAttackElement","ItemDefenseLevel","ItemDefenseType","ItemDefenseMaterial","ItemDefenseRarity","ItemDefenseQuality","ItemDefenseElement","ItemSpellLevel","ItemSpellType", "ItemSpellEnergy","ItemSpellRarity","ItemSpellQuality","ItemSpellElement","ItemBuffLevel","ItemBuffType","ItemBuffVintage","ItemBuffRarity","ItemBuffQuality","ItemBuffPotency","BossDropLevel","BossDropType","BossDropRarity","BossDropQuality","BossDropElement","ItemOne"]

    renderer = await deployProxied("MetaAndMagicRenderer");

    for (let i = 0; i < inventoryContracts.length; i++) {
        // deploying dummy items
        const Contract = await hre.ethers.getContractFactory(inventoryContracts[i], "0xc41494Fc8890c05848d2Aa26281b13449a1A8928");

        let inv = await deploy(inventoryContracts[i]);

        let sigs = []
        Contract.interface.fragments.forEach((frag) => {
          sigs.push(Contract.interface.encodeFunctionData(frag));
          // renderer.setSvg(Contract.interface.encodeFunctionData(frag), inv.address);
        })
        renderer.setSvgs(sigs, inv.address)
    }

   let hDeck = await deploy("HeroesDeck");
   let iDeck = await deploy("ItemsDeck")
   
   renderer.setDeck(1, hDeck.address);
   renderer.setDeck(2, iDeck.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
