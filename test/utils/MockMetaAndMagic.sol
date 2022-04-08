// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { MetaAndMagic, MetaAndMagicLike } from "../../contracts/MetaAndMagic.sol";


contract MockMetaAndMagic is MetaAndMagic {

    function validateItems(uint16[5] memory items) external view {
        return _validateItems(_getPackedItems(items));
    }

    // function getScore(uint256 boss, uint256 hero, bytes10 packedItems) external  returns(uint256) {
    //     return _calculateScore(boss, bosses[boss].stats, hero, packedItems, msg.sender);
    // }

    // function getCombat(bytes8 boss, uint256 hero, bytes10 packedItems) external returns(Combat memory c) {
    //     c = _calc(boss, hero, packedItems);
    // }

    function getScore(uint256 boss, bytes8 bossStats, uint256 hero, bytes10 packedItems) external returns(uint256) {
        return _calculateScore(boss, bossStats, hero, packedItems, msg.sender);
    }

    // function _calculateScore(bytes8 bossStats, uint256 heroId, bytes10 packedItems) internal override returns (uint256) {
    //     if (nextScore == 0) {
    //         return super._calculateScore(bossStats, heroId, packedItems);
    //     } else {
    //         return nextScore;
    //     }
    // }

    // function getRes(Combat memory combat, bytes8 bossStats) external returns (uint256 heroAtk, uint256 bossAtk) {
    //     return _getRes(combat, bossStats);
    // }

    // function getResult(Combat memory combat, bytes8 bossStats) external returns (uint256) {
    //     return _getResult(combat, bossStats);
    // }

    function get(bytes10 src, uint8 st) public pure returns (uint256) {
        return _get(src, Stat(st));
    }

     function _getRes(Combat memory combat, bytes8 bossStats) internal returns (uint256 heroAtk, uint256 bossAtk) {
        uint256 bossPhy = combat.phyRes * _get(bossStats, Stat.PHY_DMG)  / precision;
        uint256 bossMgk = combat.mgkRes * _get(bossStats, Stat.MGK_DMG) * precision / precision;

        heroAtk = combat.phyDmg + combat.mgkDmg; // total boss HP
        bossAtk = bossPhy + bossMgk;
    }

    event log(string bv);
    event log_named_uint(string bv, uint256 vas);

    // function _calc(bytes8 bossStats, uint256 heroId, bytes10 packedItems) internal returns (Combat memory combat) {
    //     (bytes32 s1_, bytes32 s2_) = MetaAndMagicLike(heroesAddress).getStats(heroId);

    //     // Start with empty combat
    //     combat = Combat(0,0,0,precision,precision);
        
    //     // Tally Hero modifies the combat memory inplace
    //     _tally(combat, s1_, s2_, bossStats);
    //     uint16[5] memory items_ = _unpackItems(packedItems);
    //     for (uint256 i = 0; i < 5; i++) {
    //         if (items_[i] == 0) break;
    //         (s1_, s2_) = MetaAndMagicLike(itemsAddress).getStats(items_[i]);
    //         // emit log("Combat Numbers: ");
    //         // emit log_named_uint("   | Total hero HP", combat.hp);
    //         // emit log_named_uint("   | Total hero phy_dmg", combat.phyDmg);
    //         // emit log_named_uint("   | Total hero mgk_dmg", combat.mgkDmg);
    //         // emit log("");
    //         // emit log("    Stacked variables (1e12 == 1)");
    //         // emit log_named_uint("   | Hero stacked phy_res", combat.phyRes);
    //         // emit log_named_uint("   | Hero stacked mgk_res", combat.mgkRes);
    //         // emit log("");
    //         _impTally(combat, s1_, s2_, bossStats);
    //     }
    // }

    // function _impTally(Combat memory combat, bytes32 s1_, bytes32 s2_, bytes8 bossStats) internal {
    //     uint256 bossPhyPen = _get(bossStats, Stat.PHY_PEN);
    //     bool bossPhyRes = _get(bossStats, Stat.PHY_RES) == 1;
    //     uint256 bossMgkPen = _get(bossStats, Stat.MGK_PEN);
    //     bool bossMgkRes = _get(bossStats, Stat.MGK_RES) == 1;

    //     // Stack elements into modifiers (but with 0.5 / 2 instead of 0.5 / 1)
    //     uint256 itemElement = _get(s2_, Stat.ELM);
    //     uint256 bossElement = uint8(uint64(bossStats) >> 8);

    //     // // Plain sum elements
    //     combat.hp     += _sum(Stat.HP,      s1_) + _sum(Stat.HP,      s2_);
    //     combat.phyDmg += _sumAtk(s1_, Stat.PHY_DMG, Stat.PHY_PEN, bossPhyRes) + _sumAtk(s2_, Stat.PHY_DMG, Stat.PHY_PEN, bossPhyRes);
    //     uint256 mgk = (_sumAtk(s1_, Stat.MGK_DMG, Stat.MGK_PEN, bossMgkRes) + _sumAtk(s2_, Stat.MGK_DMG, Stat.MGK_PEN, bossMgkRes));
    //     uint256 adv = _getAdv(itemElement, bossElement);

    //     combat.mgkDmg += adv == 3 ?  0 : mgk * (adv == 1 ? 2 : 1) / (adv == 2 ? 2 : 1);

    //     // // TODO this looks bad, figure it out a way to optimize it
    //     // // Stacked Elements
    //     combat.phyRes = _stack(Stat.PHY_RES, combat.phyRes, s1_, bossPhyPen);
    //     combat.phyRes = _stack(Stat.PHY_RES, combat.phyRes, s2_, bossPhyPen);
    //     // emit Par(combat.mgkRes);
    //     combat.mgkRes = _stack(Stat.MGK_RES, combat.mgkRes, s1_, bossMgkPen);
    //     // emit Par(combat.mgkRes);
    //     combat.mgkRes = _stack(Stat.MGK_RES, combat.mgkRes, s2_, bossMgkPen);
    //     // emit Par(combat.mgkRes);

    //     combat.mgkRes = stackElement(combat.mgkRes, itemElement, bossElement);
    //     // emit Par(combat.mgkRes);
    // }

    // State set function
    function setFight(bytes32 id, uint256 hero, uint256 boss, bytes10 items, uint256 start, uint256 count, bool claimed, bool claimedBoss) external {
        fights[id] = Fight(uint16(hero), uint16(boss), items, uint32(start), uint32(count), claimed, claimedBoss);
    }

    function setBossStats(uint256 id, bytes8 stats) external {
        bosses[id].stats = stats;
    }

    function setBossHighScore(uint256 boss, uint256 hs,  uint256 num) external {
        bosses[boss].highestScore = uint56(hs);
        bosses[boss].topScorers = uint16(num);
    }

    function setBossEntries(uint256 boss, uint256 entries) external {
        bosses[boss].entries = uint56(entries);
    }

    function setBosswinIndex(uint256 boss, uint256 winningIndex) external {
        bosses[boss].winIndex = uint56(winningIndex);
    }
  
}
