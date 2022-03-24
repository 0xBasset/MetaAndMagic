// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { MetaAndMagic } from "../../MetaAndMagic.sol";
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
        if (nextScore != 0) {
            return _calculateScore(bosses[boss].stats, hero, packedItems);
        } else {
            return nextScore;
        }
    }

    function getScore(bytes8 boss, uint256 hero, bytes10 packedItems) external  returns(uint256) {
        return _calculateScore(boss, hero, packedItems);
    }


    function setNextScore(uint256 s) external {
        nextScore = s;
    }

    function get(bytes32 src, uint8 st, uint256 index) public returns (uint256) {
        return _get(src, st, index);
    }

}

contract Heroes is ERC721 {

    constructor () {
        deck = new HeroDeck();
    }

    mapping (uint256 => uint16[6]) public getHeroAttributes;
    function setAttributes(uint256 id_, uint256[5] memory atts) external {
        for (uint256 i = 0; i < atts.length; i++) {
            getHeroAttributes[id_][i] = uint16(atts[i]);  
         
        }
    }

    HeroDeck deck;

    function getStats(uint256 itemId) external returns(bytes32, bytes32) {
        uint256[6] memory atts;
        atts[0] =  getHeroAttributes[itemId][0];
        atts[1] =  getHeroAttributes[itemId][1];
        atts[2] =  getHeroAttributes[itemId][2];
        atts[3] =  getHeroAttributes[itemId][3];
        atts[4] =  getHeroAttributes[itemId][4];

        return DeckLike(deck).getStats(atts);
    }

}

contract Items is ERC721 {

    mapping(uint256 => address) classDecks;
    mapping(uint256 => uint256) bossSupply;
    mapping(uint256 => uint16[6]) public getAttributes;

    constructor() {
        classDecks[0] = address(new AttackItemsDeck());
        classDecks[1] = address(new DefenseItemsDeck());
        classDecks[2] = address(new SpellItemsDeck());
        classDecks[3] = address(new BuffItemsDeck());
    }

    function getStats(uint256 itemId) external view returns(bytes32, bytes32) {
        uint256[6] memory atts;
        atts[0] =  getAttributes[itemId][0];
        atts[1] =  getAttributes[itemId][1];
        atts[2] =  getAttributes[itemId][2];
        atts[3] =  getAttributes[itemId][3];
        atts[4] =  getAttributes[itemId][4];

        return DeckLike(classDecks[itemId % 4]).getStats(atts);
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

    function mintDrop(uint256 bossId, address to_) external returns (uint256 id){
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
