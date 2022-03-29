// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/// @dev Contract responsible for handling metadata requests for both Heroes and Items address
contract MetaAndMagicRenderer {

    address heroesAddress;
    address itemsAddress;

    function getUri(uint256 tokenId) external view returns (string memory) {

    }

    function getHeroMetadata(uint256 id) internal view {
        // get stats
        (bytes32 s1, bytes32 s2) = (bytes32(0), bytes32(0));
        for (uint256 i = 0; i < 3; i++) {
            
        }
    }
    
}



