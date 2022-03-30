// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import { MetaAndMagic, MetaAndMagicBaseTest } from "./MetaAndMagic.t.sol";

import "../Deck.sol";

contract CalculateScoreTest is MetaAndMagicBaseTest {

    uint256 heroId = 1;

    HeroesDeck deck;
    ItemsDeck  itemsDeck;

    function setUp() public override {
        super.setUp();

        deck = new HeroesDeck();
        itemsDeck = new ItemsDeck();
    }

    function test_scoreSimulation_boss1() external {
        uint256 runs = 10;
        for (uint256 j = 0; j < runs; j++) {
            uint256 entropy = uint256(keccak256(abi.encode(j, "ENTROPY")));
            emit log("---------------------------------------------------");
            emit log("Boss: 1");
            emit log("        | hp:      1000");
            emit log("        | phy_dmg: 2000");
            emit log("        | mgk_dmg: 0");
            emit log("        | element: none");

            emit log("");
            emit log("Hero Attributes:");

            // Build hero 
            heroes.setEntropy(uint256(keccak256(abi.encode(entropy, "HEROES")))); 
            uint256[6] memory t = heroes.getTraits(1);
            string[6] memory n = deck.getTraitsNames(t);
            emit log_named_string("        | Level  ", n[0]);
            emit log_named_string("        | Class  ", n[1]);
            emit log_named_string("        | Rank   ", n[2]);
            emit log_named_string("        | Rarity ", n[3]);
            emit log_named_string("        | Pet    ", n[4]);
            emit log_named_string("        | Item   ", n[5]);

            emit log("");

            items.setEntropy(uint256(keccak256(abi.encode(entropy, "ITEMS"))));

            // get a few items
            uint num_items = _getRanged(entropy, 0, 6, "num items");
            uint16[5] memory items_ = [uint16(0),0,0,0,0];
            for (uint16 index = 1; index < num_items; index++) {
                items_[index - 1] = index;
                t = items.getTraits(index);
                string[6] memory n = itemsDeck.getTraitsNames(t);
                emit log_named_uint("Item ", index);
                emit log_named_string("        | Level                   ", n[0]);
                emit log_named_string("        | Kind                    ", n[1]);
                emit log_named_string("        | Material/Energy/Vintage ", n[2]);
                emit log_named_string("        | Rarity                  ", n[3]);
                emit log_named_string("        | Quality                 ", n[4]);
                emit log_named_string("        | Element / Potency       ", n[5]);
                emit log("");
            }

            // Set Boss 1
            uint256 bossHp  = 1000;
            uint256 bossAtk = 2000;
            uint256 bossMgk = 0;
            uint256 bossMod = 0;

            bytes8 bossStats = bytes8(abi.encodePacked(bossHp, bossAtk, bossMgk, bossMod));

            MetaAndMagic.Combat memory c = meta.getCombat(bossStats, 1, _getPackedItems(items_));
            // uint256 score = meta.getScore(bossStats, 1, _getPackedItems(items_));
            emit log("Combat Numbers: ");
            emit log_named_uint("   | Total hero HP", c.hp);
            emit log_named_uint("   | Total hero phy_dmg", c.phyDmg);
            emit log_named_uint("   | Total hero mgk_dmg", c.mgkDmg);
            emit log("");
            emit log("    Stacked variables (1e12 == 1)");
            emit log_named_uint("   | Hero stacked phy_res", c.phyRes);
            emit log_named_uint("   | Hero stacked mgk_res", c.mgkRes);
            // emit log_named_uint("   | Boss stacked phy_res", c.bossPhyRes);
            // emit log_named_uint("   | Boss stacked mgk_res", c.bossMgkRes);
            emit log("");

            (uint256 heroAttack, uint256 bossPhny) = meta.getRes(c, bossStats);
            emit log_named_uint("Hero Attack", heroAttack);
            emit log_named_uint("Boss Attack", bossPhny);

            emit log("");
            emit log_named_uint("Final Result", meta.getResult(c, bossStats));  
        }

    }

    function _getRanged(uint256 entropy, uint256 start, uint256 end, string memory salt) internal pure returns(uint256 rdn) {
        rdn = uint256(keccak256(abi.encodePacked(entropy, salt))) % (end - start) + start;
    }

}
