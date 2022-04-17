// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import { MetaAndMagic, MetaAndMagicBaseTest } from "./MetaAndMagic.t.sol";

import "../contracts/inventory/Names.sol";

contract CalculateScoreTest is MetaAndMagicBaseTest {

    uint256 heroId = 1;

    HeroesDeck deck;
    ItemsDeck  itemsDeck;

    mapping (uint256 => Bosses) bosses;
 
    struct Bosses {
        uint256 hp;
        uint256 atk;
        uint256 mgk;
        uint256 mod;
        uint256 ele;
    }

    uint256 bossHp;
    uint256 bossAtk;
    uint256 bossMgk;
    uint256 bossMod;
    uint256 bossEle;

    bytes8 bossStats;
    uint256 bossId;


    function setUp() public override {
        super.setUp();

        deck = new HeroesDeck();
        itemsDeck = new ItemsDeck();

        bosses[1]  = Bosses(5000,4000,0,0,0);
    }

    function test_scoreSimulation_boss() external {

        bossId =1;
        // _simulate(1,bossId);    
        // _simulate(2,bossId);    
        // _simulate(3,bossId);    
        // _simulate(4,bossId);    
    }

    function _simulate(uint256 deckStrengh, uint256 boss) internal {
        bossHp  = bosses[boss].hp;
        bossAtk = bosses[boss].atk;
        bossMgk = bosses[boss].mgk;
        bossMod = bosses[boss].mod;
        bossEle = bosses[boss].ele;

        uint256 runs = 500;
        uint256 wins;
        uint256 losses;
        emit log_named_string("///////////  Deck: ", deckStrengh == 1 ? "WEAK" : deckStrengh == 2 ? "AVG" : "STRONG");
        for (uint256 j = 498; j < runs; j++) {
            emit log_named_uint("fight: ", j);
            uint256 entropy = uint256(keccak256(abi.encode(j, "ENTROPY")));
            emit log("---------------------------------------------------");
            emit log_named_uint("Boss: ", boss);
            emit log_named_uint("        | hp:      ", bossHp);
            emit log_named_uint("        | phy_dmg: ", bossAtk);
            emit log_named_uint("        | mgk_dmg: ", bossMgk);
            emit log_named_uint("        | element: ", bossEle);

            emit log("");
            emit log("Hero Attributes:");

            // Build hero 
            heroes.setEntropy(uint256(keccak256(abi.encode(entropy, "HEROES")))); 
            uint256[6] memory t = heroes.getTraits(1);
            string[6] memory n = deck.getTraitsNames(1, t);
            emit log_named_string("        |", n[0]);
            emit log_named_string("        |", n[1]);
            emit log_named_string("        |", n[2]);
            emit log_named_string("        |", n[3]);
            emit log_named_string("        |", n[4]);
            emit log_named_string("        |", n[5]);

            emit log("");

            items.setEntropy(uint256(keccak256(abi.encode(entropy, "ITEMS"))));

            // get a few items
            uint256 num_items;
            if (deckStrengh == 1) {
                num_items = 0;
            } else if (deckStrengh == 2) {
                num_items = 1;
            } else if (deckStrengh == 3) {
                num_items = 3;
            } else if (deckStrengh == 4) {
                num_items = 5;

            }   

            emit log_named_uint("num items: ", num_items);
            uint16[5] memory items_ = [uint16(0),0,0,0,0];
            // items.getTraitsD(11);
            for (uint16 index = 0; index < num_items; index++) {
                items_[index] = index + 10;
                t = items.getTraits(index + 10);
                n = itemsDeck.getTraitsNames(index + 10, t);
                emit log_named_uint("Item ", index + 1);
                emit log_named_string("        | Level                   ", n[0]);
                emit log_named_string("        | Kind                    ", n[1]);
                emit log_named_string("        | Material/Energy/Vintage ", n[2]);
                emit log_named_string("        | Rarity                  ", n[3]);
                emit log_named_string("        | Quality                 ", n[4]);
                emit log_named_string("        | Element / Potency       ", n[5]);
                emit log("");
            }

            bossStats = bytes8(abi.encodePacked(uint16(bossHp),uint16(bossAtk),uint16(bossMgk), uint8(bossEle), uint8(bossMod)));

            MetaAndMagic.Combat memory c = meta.getCombat(boss, bossStats, 1, _getPackedItems(items_));
            // uint256 score = meta.getScSore(bossStats, 1, _getPackedItems(items_));
            emit log("Combat Numbers: ");
            emit log_named_uint("   | Total hero HP", c.hp);
            emit log_named_uint("   | Total hero phy_dmg", c.phyDmg);
            emit log_named_uint("   | Total hero mgk_dmg", c.mgkDmg);
            emit log("");
            emit log("    Stacked variables (1e12 == 1)");
            emit log_named_uint("   | Hero stacked phy_res", c.phyRes);
            emit log_named_uint("   | Hero stacked mgk_res", c.mgkRes);
            emit log("");

            (uint256 heroAttack, uint256 bossPhny) = meta.getRes(c, bossStats, heroId, bossId, _getPackedItems(items_));
            emit log_named_uint("Hero Attack", heroAttack);
            emit log_named_uint("Boss Attack", bossPhny);

            emit log("");
            uint256 sc = meta.getResult(c, bossStats, heroId, bossId, _getPackedItems(items_));
            if (sc == 0) {
                losses++;
            } else {
                wins++;
            }
            emit log_named_uint("Final Result", sc);  
        }
        emit log("**********************");
        emit log_named_uint("wins    :", wins);
        emit log_named_uint("losses  :", losses);
        emit log("**********************");
    }

    function _getRanged(uint256 entropy, uint256 start, uint256 end, string memory salt) internal pure returns(uint256 rdn) {
        rdn = uint256(keccak256(abi.encodePacked(entropy, salt))) % (end - start) + start;
    }

}
