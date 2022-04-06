// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { MerkleProof } from "./MerkleProof.sol";

contract Sale {

    // Sale Parameters
    /**
            
            Sale Information

            2 different tokens (Heros and Items) 
                Heroes: 3k supply
                Items: 10k supply

            3 different whitelists
                A: Mint 1 item
                B: Mint 1 hero
                c: Mint 2 items

            Prices:
            WL items: 0.1 ether
            PS items: 0.2 ether
            WL hero:  0.25 ether
            PS hero:  0.5 ether

            Steps:

            1. Items WL mint 
            2. If there are leftovers, Hero WL can mint remaining items
            3. If there are leftovers, public sale for items
            4. Heroes WL mint
            5. Hereos public sale
    */


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

    mapping(address => uint256) itemsMinted;
    mapping(address => uint256) heroesMinted;

    bytes32 root;


    constructor() {
        admin = msg.sender;

        itemsLeft  = 10_000;
        heroesLeft = 3_000;
    }


    // ADMIN FUNCTION
    function moveStage() external {
        require(msg.sender == admin, "not allowed");

        stage++;
    }

    function withdraw(address destination) external {
        require(msg.sender == admin, "not allowed");

        (bool succ, ) = destination.call{value: address(this).balance}("");
        require(succ, "failed");
    }

    function mint() external payable returns(uint256 id) {
        require(stage == 3 ||stage == 5, "not on public sale");
        bool isItems = stage == 3;
        
        // Make sure use sent enough money
        require((isItems ? PS_ITEM_PRICE : PS_HERO_PRICE) == msg.value, "not enough sent");

        // Make sure that user is only minting the allowed amount
        require((isItems ? itemsMinted[msg.sender] : heroesMinted[msg.sender]) < PS_MAX, "already minted");

        // Effects
        isItems ? itemsMinted[msg.sender]++ : heroesMinted[msg.sender]++;
        isItems ? itemsLeft-- : heroesLeft--;   

        // Interactions
        id = IERC721(isItems ? itemsAddress : heroesAddress).mint(msg.sender, 1);
    }

    function mint(uint256 allowedAmount, uint8 stage_, uint256 amount,  bytes32[] calldata proof_) external payable returns(uint256 id){
        bool isItems = stage == 3;

        // Make sure use sent enough money
        require((isItems ? WL_ITEM_PRICE : WL_HERO_PRICE ) * amount == msg.value, "not enough sent");

        // Make sure sale is open
        require(stage_ == stage, "wrong stage");

        // Make sure that user is only minting the allowed amount
        require((isItems ? itemsMinted[msg.sender] : heroesMinted[msg.sender]) + amount <= allowedAmount, "already minted");

        bytes32 leaf_ = keccak256(abi.encode(itemsAddress, allowedAmount, stage_, msg.sender));
        require(_verify(proof_, root, leaf_), "not on list");

        // Effects
        isItems ? itemsMinted[msg.sender] += amount : heroesMinted[msg.sender] += amount;
        isItems ? itemsLeft -= amount               : heroesLeft -= amount;

        id = IERC721(isItems ? itemsAddress : heroesAddress).mint(msg.sender, amount);
    }

    function _verify(bytes32[] memory proof_, bytes32 root_, bytes32 leaf_) internal pure returns (bool allowed) {
       allowed =  MerkleProof.verify(proof_, root_, leaf_);
    }

}


interface IERC721 {
    function mint(address to, uint256 amount) external returns (uint256 id);
}
