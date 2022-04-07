// // SPDX-License-Identifier: UNLIMITCENSED
// pragma solidity 0.8.7;

// import { MetaAndMagic, MetaAndMagicBaseTest } from "./MetaAndMagic.t.sol";

// import "../Deck.sol";

// contract CalculateScoreTest is MetaAndMagicBaseTest {

//     uint256 heroId = 1;

//     HeroesDeck deck;
//     ItemsDeck  itemsDeck;

//     // Set Boss 1
//     uint256 bossHp;
//     uint256 bossAtk;
//     uint256 bossMgk;
//     uint256 bossMod;
//     uint256 bossEle;

//     function setUp() public override {
//         super.setUp();

//         deck = new HeroesDeck();
//         itemsDeck = new ItemsDeck();
//     }

//     function test_scoreSimulation_boss1_weak() external {
//         // Setting Boss Info
//         bossHp  = 1000;
//         bossAtk = 2000;
//         bossMgk = 0;
//         bossMod = 0;
//         bossEle = 0;

//         _simulate(1);       
//     }

//     function test_scoreSimulation_boss1_avg() external {
//         // Setting Boss Info
//         bossHp  = 1000;
//         bossAtk = 2000;
//         bossMgk = 0;
//         bossMod = 0;
//         bossEle = 0;

//         _simulate(2);       
//     }

//     function test_scoreSimulation_boss1_strong() external {
//         // Setting Boss Info
//         bossHp  = 1000;
//         bossAtk = 2000;
//         bossMgk = 0;
//         bossMod = 0;
//         bossEle = 0;

//         _simulate(3);       
//     }

//     function _simulate(uint256 deckStrengh) internal {
//         uint256 runs = 300;
//         uint256 wins;
//         uint256 losses;
//         emit log_named_string("///////////  Deck: ", deckStrengh == 1 ? "WEAK" : deckStrengh == 2 ? "AVG" : "STRoNG");
//         for (uint256 j = 0; j < runs; j++) {
//             emit log_named_uint("fight: ", j);
//             uint256 entropy = uint256(keccak256(abi.encode(j, "ENTROPY")));
//             emit log("---------------------------------------------------");
//             emit log("Boss: 1");
//             emit log_named_uint("        | hp:      ", bossHp);
//             emit log_named_uint("        | phy_dmg: ", bossAtk);
//             emit log_named_uint("        | mgk_dmg: ", bossMgk);
//             emit log_named_uint("        | element: ", bossEle);

//             emit log("");
//             emit log("Hero Attributes:");

//             // Build hero 
//             heroes.setEntropy(uint256(keccak256(abi.encode(entropy, "HEROES")))); 
//             uint256[6] memory t = heroes.getTraits(1);
//             string[6] memory n = deck.getTraitsNames(t);
//             emit log_named_string("        | Level  ", n[0]);
//             emit log_named_string("        | Class  ", n[1]);
//             emit log_named_string("        | Rank   ", n[2]);
//             emit log_named_string("        | Rarity ", n[3]);
//             emit log_named_string("        | Pet    ", n[4]);
//             emit log_named_string("        | Item   ", n[5]);

//             emit log("");

//             items.setEntropy(uint256(keccak256(abi.encode(entropy, "ITEMS"))));

//             // get a few items
//             uint256 num_items;
//             if (deckStrengh == 1) {
//                 // weak deck
//                 num_items = _getRanged(entropy, 0, 2, "num items");
//             } else if (deckStrengh == 2) {
//                 num_items = _getRanged(entropy, 2, 4, "num items");
//             } else {
//                 num_items = _getRanged(entropy, 4, 6, "num items");
//             }   
//             emit log_named_uint("num items: ", num_items);
//             uint16[5] memory items_ = [uint16(0),0,0,0,0];
//             for (uint16 index = 0; index < num_items; index++) {
//                 items_[index] = index + 10;
//                 t = items.getTraits(index + 10);
//                 n = itemsDeck.getTraitsNames(t);
//                 emit log_named_uint("Item ", index + 1);
//                 emit log_named_string("        | Level                   ", n[0]);
//                 emit log_named_string("        | Kind                    ", n[1]);
//                 emit log_named_string("        | Material/Energy/Vintage ", n[2]);
//                 emit log_named_string("        | Rarity                  ", n[3]);
//                 emit log_named_string("        | Quality                 ", n[4]);
//                 emit log_named_string("        | Element / Potency       ", n[5]);
//                 emit log("");
//             }

//             bytes8 bossStats = bytes8(abi.encodePacked(uint16(bossHp),uint16(bossAtk),uint16(bossMgk), uint8(bossEle), uint8(bossMod)));

//             MetaAndMagic.Combat memory c = meta.getCombat(bossStats, 1, _getPackedItems(items_));
//             // uint256 score = meta.getScore(bossStats, 1, _getPackedItems(items_));
//             emit log("Combat Numbers: ");
//             emit log_named_uint("   | Total hero HP", c.hp);
//             emit log_named_uint("   | Total hero phy_dmg", c.phyDmg);
//             emit log_named_uint("   | Total hero mgk_dmg", c.mgkDmg);
//             emit log("");
//             emit log("    Stacked variables (1e12 == 1)");
//             emit log_named_uint("   | Hero stacked phy_res", c.phyRes);
//             emit log_named_uint("   | Hero stacked mgk_res", c.mgkRes);
//             emit log("");

//             (uint256 heroAttack, uint256 bossPhny) = meta.getRes(c, bossStats);
//             emit log_named_uint("Hero Attack", heroAttack);
//             emit log_named_uint("Boss Attack", bossPhny);

//             emit log("");
//             uint256 sc = meta.getResult(c, bossStats);
//             if (sc == 0) {
//                 losses++;
//             } else {
//                 wins++;
//             }
//             emit log_named_uint("Final Result", sc);  
//         }
//         emit log("**********************");
//         emit log_named_uint("wins    :", wins);
//         emit log_named_uint("losses  :", losses);
//         emit log("**********************");
//     }

//     function _getRanged(uint256 entropy, uint256 start, uint256 end, string memory salt) internal pure returns(uint256 rdn) {
//         rdn = uint256(keccak256(abi.encodePacked(entropy, salt))) % (end - start) + start;
//     }

// }
