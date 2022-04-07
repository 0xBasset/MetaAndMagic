// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../../modules/ds-test/src/test.sol";

import "./utils/Mocks.sol";

import "./utils/Interfaces.sol";

import "../Proxy.sol";

contract HeroesTest is DSTest {
    MockMetaAndMagic meta;
    HeroesMock       heroes;
    ItemsMock        items;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public virtual {
        heroes = HeroesMock(address(new Proxy(address(new HeroesMock()))));
        heroes.initialize(address(new HeroStats()), address(0));
        heroes.setEntropy(uint256(keccak256(abi.encode("ENTROPY"))));

        heroes.setAuth(address(this), true);
    }

    function test_mint() public {
        uint256 id = heroes.mint(address(this), 1);

        assertEq(heroes.ownerOf(id), address(this));
        assertEq(heroes.totalSupply(), 1);
        assertEq(heroes.balanceOf(address(this)), 1);
    }

    // function test_transfer_authed(uint256 id, address from, address to) public {
    //     heroes.mint(address(from), id);

    //     vm.expectRevert("NOT_APPROVED");
    //     heroes.transferFrom(from, to, id);

    //     heroes.setAuth(address(this), true);
    //     heroes.transferFrom(from, to , id);

    //     assertEq(heroes.ownerOf(id), to);
    //     assertEq(heroes.balanceOf(from), 0);
    //     assertEq(heroes.balanceOf(to), 1);
    // }
}
