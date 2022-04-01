// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { MetaAndMagic, MetaAndMagicLike } from "../../MetaAndMagic.sol";
import { Heroes }       from "../../Heroes.sol";  
import { Items }        from "../../Items.sol";
import { Proxy }        from "../../Proxy.sol";
import { ERC721 }       from "../../ERC721.sol";
import "../../Stats.sol";

contract MockMetaAndMagic is MetaAndMagic {

    uint256 nextScore;

    // Exposing internal functions

    function fight(uint256 heroId, bytes10 items) external returns(bytes32 fightId) {
        return _fight(heroId, items);
    }

    function validateItems(uint16[5] memory items) external view {
        return _validateItems(_getPackedItems(items));
    }

    function getScore(uint256 boss, uint256 hero, bytes10 packedItems) external  returns(uint256) {
        return _calculateScore(bosses[boss].stats, hero, packedItems);
    }

    function getCombat(bytes8 boss, uint256 hero, bytes10 packedItems) external returns(Combat memory c) {
        c = _calc(boss, hero, packedItems);
    }

    function getScore(bytes8 boss, uint256 hero, bytes10 packedItems) external returns(uint256) {
        return _calculateScore(boss, hero, packedItems);
    }

    function _calculateScore(bytes8 bossStats, uint256 heroId, bytes10 packedItems) internal override returns (uint256) {
        if (nextScore == 0) {
            return super._calculateScore(bossStats, heroId, packedItems);
        } else {
            return nextScore;
        }
    }

    function getRes(Combat memory combat, bytes8 bossStats) external returns (uint256 heroAtk, uint256 bossAtk) {
        return _getRes(combat, bossStats);
    }

    function getResult(Combat memory combat, bytes8 bossStats) external returns (uint256) {
        return _getResult(combat, bossStats);
    }

    function setNextScore(uint256 s) external {
        nextScore = s;
    }

    function get(bytes32 src, uint8 st, uint256 index) public returns (uint256) {
        return _get(src, Stat(st), index);
    }

    event D(string k, uint256 val);

     function _getRes(Combat memory combat, bytes8 bossStats) internal returns (uint256 heroAtk, uint256 bossAtk) {
        uint256 bossPhy = combat.phyRes * _get(bossStats, Stat.PHY_DMG)  / precision;
        uint256 bossMgk = combat.mgkRes * _get(bossStats, Stat.MGK_DMG) * precision / precision;

        heroAtk = combat.phyDmg + combat.mgkDmg; // total boss HP
        bossAtk = bossPhy + bossMgk;
    }


    function _calc(bytes8 bossStats, uint256 heroId, bytes10 packedItems) internal returns (Combat memory combat) {
        (bytes32 s1_, bytes32 s2_) = MetaAndMagicLike(heroesAddress).getStats(heroId);

        // Start with empty combat
        combat = Combat(0,0,0,precision,precision,precision,precision);
        
        // Tally Hero modifies the combat memory inplace
        _tally(combat, s1_, s2_, bossStats);
        uint16[5] memory items_ = _unpackItems(packedItems);
        for (uint256 i = 0; i < 6; i++) {
            if (items_[i] == 0) break;
            (s1_, s2_) = MetaAndMagicLike(itemsAddress).getStats(items_[i]);
            _tally(combat, s1_, s2_, bossStats);
        }
    }

}

contract HeroesMock is Heroes {

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    mapping (uint256 => uint16[6]) public getHeroAttributes;
    function setAttributes(uint256 id_, uint256[6] memory atts) external {
        for (uint256 i = 0; i < atts.length; i++) {
            getHeroAttributes[id_][i] = uint16(atts[i]);  
         
        }
    }

    function getStats(uint256 itemId) external view override returns(bytes32, bytes32) {
        if (getHeroAttributes[itemId][0] == 0) return StatsLike(stats).getStats(_traits(entropySeed, itemId));
        uint256[6] memory atts;
        
        atts[0] =  getHeroAttributes[itemId][0];
        atts[1] =  getHeroAttributes[itemId][1];
        atts[2] =  getHeroAttributes[itemId][2];
        atts[3] =  getHeroAttributes[itemId][3];
        atts[4] =  getHeroAttributes[itemId][4];
        atts[5] =  getHeroAttributes[itemId][5];

        return StatsLike(stats).getStats(atts);
    }

}

contract ItemsMock is Items {

    
    mapping(uint256 => uint256) bossSupply;
    mapping(uint256 => uint16[6]) public getAttributes;

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function getStats(uint256 itemId) external view override returns(bytes32, bytes32) {
        if (getAttributes[itemId][0] == 0) return StatsLike(statsAddress[(itemId % 4) + 1]).getStats(_traits(entropySeed, itemId));
        
        uint256[6] memory atts;
        atts[0] =  getAttributes[itemId][0];
        atts[1] =  getAttributes[itemId][1];
        atts[2] =  getAttributes[itemId][2];
        atts[3] =  getAttributes[itemId][3];
        atts[4] =  getAttributes[itemId][4];
        atts[5] =  getAttributes[itemId][5];
    }

    function setAttributes(uint256 id_, uint256[6] memory atts) external {
        for (uint256 i = 0; i < atts.length; i++) {
            getAttributes[id_][i] = uint16(atts[i]);  
        }
    }

    function burnFrom(address from, uint256 id) external returns (bool) {
        require(ownerOf[id] == from, "not owner");
        _burn(id);
        return true;
    }

    function mintDrop(uint256 bossId, address to_) external override returns (uint256 id){
        id = 10000 + (bossId * 100) + ++bossSupply[bossId];
        _mint(to_, id);
    }
    
    function mintFive(address to, uint16 fst, uint16 sc,uint16 thr,uint16 frt,uint16 fifth)  external returns(uint16[5] memory list) {
        _mint(to, fst);
        _mint(to, sc);
        _mint(to, thr);
        _mint(to, frt);
        _mint(to, fifth);

        list = [fst,sc,thr,frt, fifth];
    }
}

interface VRFConsumer {
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWord) external;
}

contract VRFMock {

    uint256 nonce;
    uint256 reqId;
    address consumer;


    function requestRandomWords( bytes32 , uint64 , uint16 , uint32 , uint32 ) external returns (uint256 requestId) {
        requestId = uint256(keccak256(abi.encode("REQUEST", nonce++)));
        reqId = requestId;
    }

    function fulfill() external {
        uint256[] memory words = new uint256[](1);
        words[0] = uint256(keccak256(abi.encode("REQUEST", reqId, consumer, nonce++)));
        VRFConsumer(consumer).fulfillRandomWords(reqId, words);
    }


}
