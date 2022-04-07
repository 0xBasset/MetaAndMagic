// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { MerkleProof } from "./MerkleProof.sol";

contract Sale {

    uint256 constant WL_ITEM_PRICE = 0.1  ether;
    uint256 constant PS_ITEM_PRICE = 0.2  ether;
    uint256 constant WL_HERO_PRICE = 0.25 ether;
    uint256 constant PS_HERO_PRICE = 0.5  ether;
    uint256 constant PS_MAX  = 1;


    uint8 stage; // 0 -> init, 1 -> item wl sale, 2 -> items hero sale, 3 -> items public sale, 4 -> hero wl, 5 -> hero ps, 6 -> finalized

    address admin;
    address heroesAddress; 
    address itemsAddress;

    uint256 itemsLeft;
    uint256 heroesLeft;

    bytes32 root;


    constructor() {
        admin = msg.sender;

        itemsLeft  = 10_000;
        heroesLeft = 3_000;
    }

    // ADMIN FUNCTION
    function moveStage() external {
        require(msg.sender == _owner(), "not allowed");

        stage++;
    }

    function withdraw(address destination) external {
        require(msg.sender == _owner(), "not allowed");

        (bool succ, ) = destination.call{value: address(this).balance}("");
        require(succ, "failed");
    }

    function mint() external payable returns(uint256 id) {
        require(stage == 3 ||stage == 5, "not on public sale");
        bool isItems = stage == 3;
        
        // Make sure use sent enough money
        require((isItems ? PS_ITEM_PRICE : PS_HERO_PRICE) == msg.value, "not enough sent");

        // Make sure that user is only minting the allowed amount
        uint256 minted  = IERC721MM(isItems ? itemsAddress : heroesAddress).minted(msg.sender);
        require(minted < PS_MAX, "already minted");

        // Effects
        isItems ? itemsLeft-- : heroesLeft--;   

        // Interactions
        id = IERC721MM(isItems ? itemsAddress : heroesAddress).mint(msg.sender, 1);
    }

    function mint(uint256 allowedAmount, uint8 stage_, uint256 amount,  bytes32[] calldata proof_) external payable returns(uint256 id){
        bool isItems = stage == 3;

        // Make sure use sent enough money 
        require(amount > 0, "zero amount");
        require((isItems ? WL_ITEM_PRICE : WL_HERO_PRICE ) * amount == msg.value, "not enough sent");

        // Make sure sale is open
        require(stage_ == stage, "wrong stage");

        // Make sure that user is only minting the allowed amount
        uint256 minted  = IERC721MM(isItems ? itemsAddress : heroesAddress).minted(msg.sender);
        require(minted + amount <= allowedAmount, "already minted");

        bytes32 leaf_ = keccak256(abi.encode(itemsAddress, allowedAmount, stage_, msg.sender));
        require(_verify(proof_, root, leaf_), "not on list");

        // Effects
        isItems ? itemsLeft -= amount : heroesLeft -= amount;

        id = IERC721MM(isItems ? itemsAddress : heroesAddress).mint(msg.sender, amount);
    }

    function _verify(bytes32[] memory proof_, bytes32 root_, bytes32 leaf_) internal pure returns (bool allowed) {
       allowed =  MerkleProof.verify(proof_, root_, leaf_);
    }

    function _owner() internal view returns (address owner_) {
        bytes32 slot = bytes32(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);
        assembly {
            owner_ := sload(slot)
        }
    }

}

interface IERC721MM {
    function mint(address to, uint256 amount) external returns (uint256 id);
    function minted(address to) external returns (uint256 minted);
}
