// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { Heroes }       from "../contracts/Heroes.sol";  
import { Items }        from "../contracts/Items.sol";


contract HeroesMock is Heroes {

    uint256 mockminted;

    function setMinted(uint256 minted_) external {
        mockminted = minted_;
    }

    function mintFree(address to, uint256 amount) external virtual returns(uint256 id) {
        for (uint256 i = 0; i < amount; i++) {
            id = mockminted++;
            _mint(to, id);     
        }
    }

    function setEntropy(uint256 seed) external {
        entropySeed = seed;
    }

    function getSpecialSart() external view returns (uint256 rdn) {
        rdn = uint256(keccak256(abi.encode(entropySeed, "SPECIAL"))) % 2_993 + 1;
    }


}

contract ItemsMock is Items {

    uint256 mockminted;

    function setMinted(uint256 minted_) external {
        mockminted = minted_;
    }


    function mintFree(address to, uint256 amount) external virtual returns(uint256 id) {
        for (uint256 i = 0; i < amount; i++) {
            id = mockminted++;
            _mint(to, id);     
        }
    }

    function mintId(address to, uint256 id_) external virtual returns(uint256 id) {
        _mint(to, id_);    
        id = id_; 
    }

    function mintFive(address to, uint16 fst, uint16 sc,uint16 thr,uint16 frt,uint16 fifth)  external returns(uint16[5] memory list) {
        _mint(to, fst);
        _mint(to, sc);
        _mint(to, thr);
        _mint(to, frt);
        _mint(to, fifth);

        list = [fst,sc,thr,frt, fifth];
    }

    function setEntropy(uint256 seed) external {
        entropySeed = seed;
    }


    function getSpecialSart() external view returns (uint256 rdn) {
        rdn = uint256(keccak256(abi.encode(entropySeed, "SPECIAL"))) % 9_992 + 1;
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
        consumer = msg.sender;
        reqId = requestId;
    }

    function fulfill() external {
        uint256[] memory words = new uint256[](1);
        words[0] = uint256(keccak256(abi.encode("REQUEST", reqId, consumer, nonce++)));
        VRFConsumer(consumer).fulfillRandomWords(reqId, words);
    }


}
