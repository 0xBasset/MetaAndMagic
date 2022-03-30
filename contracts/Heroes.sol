// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { ERC721 } from "./ERC721.sol";


contract Heroes is ERC721 {

    string constant public name   = "Meta&Magic-Heroes";
    string constant public symbol = "M&M-HEROES";

    address stats;
    address renderer;

    uint256 entropySeed;

    // Oracle information
    address VRFcoord;
    uint64 subId;
    bytes32 keyhash;

    function initialize(address stats_, address renderer_) external {
        require(msg.sender == _owner(), "not authorized");

        stats    = stats_;
        renderer = renderer_;
    }

    function getStats(uint256 id_) external view virtual returns(bytes32, bytes32) {    // [][]
        uint256 seed = entropySeed;
        
        if (!_isSpecial(id_, seed)) return StatsLike(stats).getStats(_traits(seed, id_));
    }

    function getTraits(uint256 id_) external view returns (uint256[6] memory traits_) {
        return _traits(entropySeed, id_);
    }

    function setUpOracle(address vrf_, bytes32 keyHash, uint64 subscriptionId) external {
        require(msg.sender == _owner());

        VRFcoord = vrf_;
        keyhash  = keyHash;
        subId    = subscriptionId;
    }

    /*///////////////////////////////////////////////////////////////
                        MINT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setAuth(address add_, bool auth_) external {
        require(_owner() == msg.sender, "not authorized");
        auth[add_] = auth_;
    }

    function setEntropy(uint256 seed) external {
        entropySeed = seed;
    }

    /*///////////////////////////////////////////////////////////////
                             TRAIT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _traits(uint256 seed, uint256 id_) internal pure returns (uint256[6] memory) {
        return [_getTier(id_,  seed, "LEVEL"), 
                _getClass(id_, seed, "CLASS"), 
                _getTier(id_,  seed, "RANK"), 
                _getTier(id_,  seed, "RARITY"), 
                _getTier(id_,  seed, "PET"),
                _getItem(id_,  seed, "ITEM")];
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

    function _getClass(uint256 id_, uint256 seed, bytes32 salt) internal pure returns (uint256 class_) {
        uint256 rdn = uint256(keccak256(abi.encode(id_, seed, salt))) % 100_0000 + 1; 

        if (rdn <= 79_8160) return (rdn % 5) + 1;
        if (rdn <= 91_7884) return 6;
        return 7;
    }

    function _getItem(uint256 id_, uint256 seed, bytes32 salt) internal pure returns (uint256 item_) {
        uint256 rdn = uint256(keccak256(abi.encode(id_, seed, salt))) % 100_0000 + 1; 
        if (rdn <= 24_9425) return 0;

        return _getTier(id_, seed, salt) + ((rdn % 3) * 6);
    }

    function _isSpecial(uint256 id, uint256 seed) internal pure returns (bool special) {
        uint256 rdn = uint256(keccak256(abi.encode(seed, "SPECIAL"))) % 2_992 + 1;
        if (id > rdn && id <= rdn + 7) return true;
    }

}


interface StatsLike {
    function getStats(uint256[6] calldata attributes) external view returns (bytes32 s1, bytes32 s2); 
}
