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

async function deploy(contractName, nonce) {
  console.log("Deploying", contractName)
  const Factory = await hre.ethers.getContractFactory(contractName);
  let impl = await Factory.deploy({nonce: nonce});
  console.log(impl.address)
  await impl.deployed();
  return impl
}

async function main() {
  await hre.run("compile");

  const inventoryContracts = ["HeroRankAssassin","HeroRankMonk","HeroRankMage","HeroRankZombie","HeroRankGod", "HeroRankOracle","HeroLevel","HeroClass","HeroRankWarrior","HeroRankMarksman","HeroRarity","HeroPet", "HeroItem","HeroOne","ItemAttackLevel", "ItemAttackKind","ItemAttackMaterial","ItemAttackRarity","ItemAttackQuality","ItemAttackElement","ItemDefenseLevel","ItemDefenseType","ItemDefenseMaterial","ItemDefenseRarity","ItemDefenseQuality","ItemDefenseElement","ItemSpellLevel","ItemSpellType", "ItemSpellEnergy","ItemSpellRarity","ItemSpellQuality","ItemSpellElement","ItemBuffLevel","ItemBuffType","ItemBuffVintage","ItemBuffRarity","ItemBuffQuality","ItemBuffPotency","BossDropLevel","BossDropType","BossDropRarity","BossDropQuality","BossDropElement","ItemOne"]

    // renderer = await deployProxied("MetaAndMagicRenderer");

    let n = 93;

    renderer = await hre.ethers.getContractAt("MetaAndMagicRenderer", "0x9E899A10bF2ab5927cAFCed5d1a06f634c31CbB4"); 

    for (let i = 0; i < inventoryContracts.length; i++) {
        // deploying dummy items
        const Contract = await hre.ethers.getContractFactory(inventoryContracts[i], "0xc41494Fc8890c05848d2Aa26281b13449a1A8928");

        let inv = await deploy(inventoryContracts[i], n);
        // await new Promise(resolve => setTimeout(resolve, 10000));
        let sigs = []
        Contract.interface.fragments.forEach((frag) => {
          sigs.push(Contract.interface.encodeFunctionData(frag));
          // renderer.setSvg(Contract.interface.encodeFunctionData(frag), inv.address);
        })
        n++;
          // await new Promise(resolve => setTimeout(resolve, 10000));
        renderer.setSvgs(sigs, inv.address, {nonce: n});
        n++
    }

   let hDeck = await deploy("HeroesDeck", n);
   n++
   let iDeck = await deploy("ItemsDeck", n)
   n++
   renderer.setDeck(1, hDeck.address, {nonce:n});
   n++
   renderer.setDeck(2, iDeck.address, {nonce:n});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
