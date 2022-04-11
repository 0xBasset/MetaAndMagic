// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "../contracts/inventory/Renderer.sol";
import "../contracts/inventory/Names.sol";
import "../contracts/inventory/Inventory.sol";


contract InventoryTest is DSTest {

    function test_contract_sizes() external {
        new HeroLevel();
        new HeroClass();
        new HeroRankWarrior();
        new HeroRankMarksman();
        new HeroRankAssassin();
        new HeroRankMonk();
        new HeroRankMage();
        new HeroRankZombie();
        new HeroRankGod();
        new HeroRankOracle();
        new HeroRarity();
        new HeroPet();
        new HeroItem();
        new HeroOne();
        new ItemAttackLevel();
        new ItemAttackKind();
        new ItemAttackMaterial();
        new ItemAttackRarity();
        new ItemAttackQuality();
        new ItemAttackElement();
        new ItemDefenseLevel();
        new ItemDefenseType();
        new ItemDefenseMaterial();
        new ItemDefenseRarity();
        new ItemDefenseQuality();
        new ItemDefenseElement();
        new ItemSpellLevel();
        new ItemSpellType();
        new ItemSpellEnergy();
        new ItemSpellRarity();
        new ItemSpellQuality();
        new ItemSpellElement();
        new ItemBuffLevel();
        new ItemBuffType();
        new ItemBuffVintage();
        new ItemBuffRarity();
        new ItemBuffQuality();
        new ItemBuffPotency();
        new BossDropLevel();
        new BossDropType();
        new BossDropRarity();
        new BossDropQuality();
        new BossDropElement();
        new ItemOne();

        assertTrue(false);
    }


}

