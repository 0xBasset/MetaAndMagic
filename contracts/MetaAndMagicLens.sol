// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract MetaAndMagicLens {

    address heroesAddress;
    address itemsAddress;

    function unstakesHeroes() external view returns (uint256[] memory unstaked){
        unstaked = new uint256[](3000 - IERC721(heroesAddress).balanceOf(heroesAddress));
        uint256 counter = 0;
        for (uint256 i = 1; i < 3000; i++) {
            unstaked[counter++] = i;
        }
    }
}

interface IMetaAndMagicLike {
    function heroes(uint256 id) external view returns(address owner, int16 lastBoss, uint32 highestScore);
}

interface IERC721 {
    function totalSupply() external view returns (uint256 supply); 
    function ownerOf(uint256 id) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
}
