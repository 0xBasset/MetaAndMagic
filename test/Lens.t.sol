// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "../contracts/Mocks.sol";
import "../contracts/Proxy.sol";

import "../contracts/Stats.sol";


import "./utils/MockMetaAndMagic.sol";

import "../contracts/MetaAndMagicLens.sol";

contract LensTest is DSTest {

    MockMetaAndMagic meta;
    HeroesMock       heroes;
    ItemsMock        items;
    MetaAndMagicLens lens;

    function setUp() public virtual {

        heroes = HeroesMock(address(new Proxy(address(new HeroesMock()))));
        items  = ItemsMock(address(new Proxy(address(new ItemsMock()))));
        meta   = MockMetaAndMagic(address(new Proxy(address(new MockMetaAndMagic()))));

        meta.initialize(address(heroes), address(items));
        
        heroes.initialize(address(new HeroStats()), address(0));
        heroes.setEntropy(uint256(keccak256(abi.encode("HEROES_NTROPY"))));
        heroes.setAuth(address(meta), true);
        heroes.setAuth(address(this), true);

        // Set up items
        items.initialize(address(new AttackItemsStats()), address(new DefenseItemsStats()), address(new SpellItemsStats()), address(new BuffItemsStats()), address(new BossDropsStats()), address(0));
        items.setEntropy(uint256(keccak256(abi.encode("ITEMS_ENTROPY"))));
        items.setAuth(address(meta), true);
        items.setAuth(address(this), true);

        lens = new MetaAndMagicLens();

        lens.initialize(address(meta), address(heroes), address(items));
    }

    function test_lens() public {
        lens.stakedHeroesOf(address(this));
    }

    
}
