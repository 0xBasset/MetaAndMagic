// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "./utils/Mocks.sol";

import "./utils/MockMetaAndMagic.sol";

import "./utils/Interfaces.sol";

import "../contracts/Proxy.sol";

contract HeroesTest is DSTest {
    MockMetaAndMagic meta;
    HeroesMock       heroes;
    ItemsMock        items;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public virtual {
        heroes = HeroesMock(address(new Proxy(address(new HeroesMock()))));
        heroes.initialize(address(new HeroStats()), address(0));
        heroes.setEntropy(uint256(keccak256(abi.encode(111,"ENTROPYENTROPY"))));

        heroes.setAuth(address(this), true);
    }

    function test_mint() public {
        uint256 id = heroes.mint(address(this), 1);

        assertEq(heroes.ownerOf(id), address(this));
        assertEq(heroes.totalSupply(), 1);
        assertEq(heroes.balanceOf(address(this)), 1);
    }

    // function test_isSpecial() public {

    //     for (uint i = 0; i < 3001; i++) {
    //         if (heroes.isSpecial(i)) {
    //             emit log_named_uint("spe", i);

    //             uint256[6] memory traits = heroes.getTraits(i);

    //             for (uint256 j = 0; j < 6; j++) {
    //                 emit log_named_uint("tt", traits[j]);
    //             }
    //         }
    //     }

    // }
}
