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

    // Oracle information
    address VRFcoord;
    uint64  subId;
    bytes32 keyhash;

    function initialize(address stats_1, address stats_2, address stats_3, address stats_4, address stats_5, address renderer_) external {
        require(msg.sender == _owner(), "not authorized");

        statsAddress[0] = stats_1;
        statsAddress[1] = stats_2;
        statsAddress[2] = stats_3;
        statsAddress[3] = stats_4;
        statsAddress[9] = stats_5;
        
        renderer = renderer_;

        // Setting boss drop supplies
        bossSupplies[1] = 1000; 
        bossSupplies[2] = 900; 
        bossSupplies[3] = 800;
        bossSupplies[4] = 700;
        bossSupplies[5] = 600;
        bossSupplies[6] = 500;
        bossSupplies[7] = 400;
        bossSupplies[8] = 300;
        bossSupplies[9] = 200;
    }

    function setUpOracle(address vrf_, bytes32 keyHash, uint64 subscriptionId) external {
        require(msg.sender == _owner());

        VRFcoord = vrf_;
        keyhash  = keyHash;
        subId    = subscriptionId;
    }

    function getStats(uint256 id_) external view virtual returns(bytes10[6] memory stats_) {    
        uint256 seed = entropySeed;
        
        if (id_ > 10000) return stats_ = StatsLike(statsAddress[10]).getStats(_bossTraits(seed, id_));

        if (!_isSpecial(id_, seed)) return stats_ = StatsLike(statsAddress[(id_ % 4)]).getStats(_traits(seed, id_));
    }

    function getTraits(uint256 id_) external view returns (uint256[6] memory traits_) {
        return _traits(entropySeed, id_);
    }

    /*///////////////////////////////////////////////////////////////
                             MINT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 amount) external virtual returns(uint256 id) {
        require(auth[msg.sender], "not authorized");
        for (uint256 i = 0; i < amount; i++) {
            id = totalSupply + 1;
            _mint(to, id);     
        }
    }

    function mintDrop(uint256 boss, address to) external virtual returns(uint256 id) {
        require(auth[msg.sender], "not authorized");

        id = boss * 10_000 + bossSupplies[boss]--; // Note boss drops are predictable because the entropy seed is known

        _mint(to, id);
    }

    function burnFrom(address from, uint256 id) external returns (bool) {
        require(auth[msg.sender], "not authorized");
        _burn(from, id);
        return true;
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

    function setAuth(address add_, bool auth_) external {
        require(_owner() == msg.sender, "not authorized");
        auth[add_] = auth_;
    }

}


interface StatsLike {
    function getStats(uint256[6] calldata attributes) external view returns (bytes10[6] memory stats_); 
}
