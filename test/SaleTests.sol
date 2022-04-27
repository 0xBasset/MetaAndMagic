// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "../contracts/Mocks.sol";

import "../contracts/Stats.sol";

import "./utils/MockMetaAndMagic.sol";

import "./utils/Interfaces.sol";

import "../contracts/Sale.sol";

import "../contracts/Proxy.sol";

contract SaleTest is DSTest {
    Heroes       heroes;
    Items        items;
    MetaAndMagicSale sale;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public virtual {
        heroes = Heroes(address(new Proxy(address(new Heroes()))));
        items  = Items(address(new Proxy(address(new Items()))));
        sale   = MetaAndMagicSale(address(new Proxy(address(new MetaAndMagicSale()))));

        heroes.setAuth(address(sale), true);
        sale.initialize(address(heroes), address(items));
    }

    function test_ownerMint() public {

        sale.ownerMint(address(heroes), address(this), 50);

        (address token, uint16  left, uint16 amtPs, uint32  priceWl, uint32  pricePS) = sale.heroes();

        assertEq(left, 2950);
    }

}
