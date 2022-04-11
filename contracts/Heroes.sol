// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { ERC721 } from "./ERC721.sol";


contract Heroes is ERC721 {

    string constant public name   = "Meta&Magic-Heroes";
    string constant public symbol = "M&M-HEROES";

    mapping(uint256 => uint256) bossSupplies;

    address stats;
    address renderer;

    uint256 entropySeed;


    // Oracle information
    address VRFcoord;
    uint64  subId;
    bytes32 keyhash;

    function initialize(address stats_, address renderer_) external {
        require(msg.sender == _owner(), "not authorized");

        stats    = stats_;
        renderer = renderer_;

        bossSupplies[10] = 100;
    }

    function getStats(uint256 id_) external view virtual returns(bytes10[6] memory stats_) {    // [][]
        uint256 seed = entropySeed;
        
        stats_ = StatsLike(stats).getStats(_traits(seed, id_));
    }

    function getTraits(uint256 id_) external view returns (uint256[6] memory traits_) {
        return _traits(entropySeed, id_);
    }

    function isSpecial(uint256 id) external view returns(bool sp) {
        return _isSpecial(id, entropySeed);
    }

    function setUpOracle(address vrf_, bytes32 keyHash, uint64 subscriptionId) external {
        require(msg.sender == _owner());

        VRFcoord = vrf_;
        keyhash  = keyHash;
        subId    = subscriptionId;
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        uint256 seed = entropySeed;
        return RendererLike(renderer).getUri(id, _traits(seed, id), _getCategory(id,seed));
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

    function mint(address to, uint256 amount) external virtual returns(uint256 id) {
        require(auth[msg.sender], "not authorized");
        for (uint256 i = 0; i < amount; i++) {
            id = totalSupply + 1;
            _mint(to, id);     
        }
    }

    function mintDrop(uint256 boss, address to) external virtual returns(uint256 id) {
        require(auth[msg.sender], "not authorized");

        id = 3000 + bossSupplies[boss]--; // Note boss drops are predictable because the entropy seed is known

        _mint(to, id);
    }

    /*///////////////////////////////////////////////////////////////
                             TRAIT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _traits(uint256 seed_, uint256 id_) internal pure returns (uint256[6] memory t ) {
        require(seed_ != uint256(0), "seed not set");
        if (_isSpecial(id_, seed_)) return _getSpecialTraits(seed_, id_);
        
        t = [ _getTier(id_,  seed_, "LEVEL"), 
               _getClass(id_, seed_, "CLASS"), 
               _getTier(id_,  seed_, "RANK"), 
               _getTier(id_,  seed_, "RARITY"), 
               _getTier(id_,  seed_, "PET"),
               _getItem(id_,  seed_, "ITEM")];
            
        if (id_ > 3000) t[1] = 8;
    }

    function _getSpecialTraits(uint256 seed_, uint256 id_) internal pure returns (uint256[6] memory t) {
        uint256 rdn = uint256(keccak256(abi.encode(seed_, "SPECIAL"))) % 2_993 + 1;
        uint256 spc = id_ - rdn;
        
        uint256 traitIndcator = spc * 10 + spc;

        t = [traitIndcator,traitIndcator,traitIndcator,traitIndcator,traitIndcator,traitIndcator];
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
        uint256 rdn = uint256(keccak256(abi.encode(seed, "SPECIAL"))) % 2_993 + 1;
        if (id > rdn && id <= rdn + 7) return true;
    }

    function _getSpecialCategory(uint256 id, uint256 seed) internal pure returns (uint256 spc) {
        uint256 rdn = uint256(keccak256(abi.encode(seed, "SPECIAL"))) % 2_993 + 1;
        uint256 num = id - rdn;
        spc = num + 4 + (num - 1);
    }

    function _getCategory(uint256 id, uint256 seed) internal pure returns (uint256 cat) {
        // Boss Drop
        if (id > 3000) return cat = 3;
        if (_isSpecial(id, seed)) _getSpecialCategory(id, seed);
        return 1;
    }

}


interface StatsLike {
    function getStats(uint256[6] calldata attributes) external view returns (bytes10[6] memory stats_); 
}

interface RendererLike {
    function getUri(uint256 id, uint256[6] calldata traits, uint256 cat) external view returns (string memory meta);
}
