// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { ERC721 } from "./ERC721.sol";

contract Items is ERC721 {

    string constant public name   = "Meta&Magic-Items";
    string constant public symbol = "M&M-ITEMS";

    address renderer;
    uint256 entropySeed;

    mapping(uint256 => address) statsAddress;
    mapping(uint256 => uint256) bossSupplies;

    function initialize(address stats_1, address stats_2, address stats_3, address stats_4, address renderer_) external {
        require(msg.sender == _owner(), "not authorized");

        statsAddress[1] = stats_1;
        statsAddress[2] = stats_2;
        statsAddress[3] = stats_3;
        statsAddress[4] = stats_4;
        
        renderer = renderer_;

        // Setting boss drop supplies
        bossSupplies[2]  = 1000; 
        bossSupplies[3]  = 900; 
        bossSupplies[4]  = 800;
        bossSupplies[5]  = 700;
        bossSupplies[6]  = 600;
        bossSupplies[7]  = 500;
        bossSupplies[8]  = 400;
        bossSupplies[9]  = 300;
        bossSupplies[10] = 200;
    }

    function getStats(uint256 id_) external view virtual returns(bytes32, bytes32) {    
        uint256 seed = entropySeed;
        
        if (id_ > 10000) return StatsLike(statsAddress[10]).getStats(_bossTraits(seed, id_));

        if (!_isSpecial(id_, seed)) return StatsLike(statsAddress[(id_ % 4) + 1]).getStats(_traits(seed, id_));
    }

    function getTraits(uint256 id_) external view returns (uint256[6] memory traits_) {
        return _traits(entropySeed, id_);
    }

    /*///////////////////////////////////////////////////////////////
                             MINT FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    function mintDrop(uint256 boss, address to) external virtual returns(uint256 id) {
        require(auth[msg.sender], "not authorized");

        id = boss * 10_000 + bossSupplies[boss]--; // Note boss drops are predictable because the entropy seed is known

        _mint(to, id);
    }


    /*///////////////////////////////////////////////////////////////
                             TRAIT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _traits(uint256 seed, uint256 id_) internal pure returns (uint256[6] memory traits) {
        traits = [_getTier(id_,    seed, "LEVEL"), 
                  _getTier(id_,    seed, "KIND"), 
                  _getTier(id_,    seed, "MATERIAL"), 
                  _getTier(id_,    seed, "RARITY"), 
                  _getTier(id_,    seed, "QUALITY"),
                  _getElement(id_, seed, "ELEMENT")];
    }
    
    function _bossTraits(uint256 seed, uint256 id_) internal pure returns (uint256[6] memory traits) {
        traits = _traits(seed, id_);
        
        // Overriding kind
        traits[1] =  id_ / 10_000;
    }

    function _getTier(uint256 id_, uint256 seed, bytes32 salt) internal pure returns (uint256 t_) {
        uint256 rdn = uint256(keccak256(abi.encode(id_, seed, salt))) % 100_0000 + 1; 
        if (rdn <= 29_9333) return 1;
        if (rdn <= 52_8781) return 2;
        if (rdn <= 71_8344) return 3;
        if (rdn <= 85_8022) return 4;
        if (rdn <= 94_7815) return 5;
        return 6;
    }

    function _getElement(uint256 id_, uint256 seed, bytes32 salt) internal pure returns (uint256 class_) {
        uint256 rdn = uint256(keccak256(abi.encode(id_, seed, salt))) % 100_0000 + 1; 

        if (rdn <= 25_0000) return 0;
        return (rdn % 5) + 1;
    }

    function _isSpecial(uint256 id, uint256 seed) internal pure returns (bool special) {
        uint256 rdn = uint256(keccak256(abi.encode(seed, "SPECIAL"))) % 9_991 + 1;
        if (id > rdn && id <= rdn + 8) return true;
    }

    // TODO add chainlink
    function setEntropy(uint256 seed) external {
        entropySeed = seed;
    }

}


interface StatsLike {
    function getStats(uint256[6] calldata attributes) external view returns (bytes32 s1, bytes32 s2); 
}
