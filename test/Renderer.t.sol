// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "../contracts/inventory/Renderer.sol";
import "../contracts/inventory/Names.sol";
import "../contracts/inventory/SingleInventory.sol";


contract RendererTest is DSTest {

    MetaAndMagicRenderer renderer;
    SingleInventory      inv;

    function setUp() external {
        renderer = new MetaAndMagicRenderer();
        inv = new SingleInventory();

        setAllSigs();

        // Set names contract
        renderer.setDeck(1, address(new HeroesDeck()));
        renderer.setDeck(2, address(new ItemsDeck()));

    }

    function test_getMetadata_hero() external {
        uint256[6] memory traits = [uint256(2),2,2,2,2,2];

        string memory meta = renderer.getUri(1, traits, 1);
    }

    function test_getMetadata_item() external {
        uint256[6] memory traits = [uint256(2),2,2,2,2,2];

        string memory meta = renderer.getUri(1, traits, 2);
    }

    function test_getMetadata_heroBossDrop() external {
        uint256[6] memory traits = [uint256(2),8,2,2,2,2];

        string memory meta = renderer.getUri(3001, traits, 3);

        emit log(meta);
    }

    function test_getMetadata_itemsBossDrop() external {
        uint256[6] memory traits = [uint256(2),11,2,2,2,2];

        string memory meta = renderer.getUri(10001, traits, 4);
    }

    function test_getMetadata_hero1o1() external {
        uint256[6] memory traits = [uint256(8),8,8,8,8,8];

        string memory meta = renderer.getUri(10001, traits, 5);
    }


    // Awful
    function setAllSigs() public {
        renderer.setSvg(0xec0931bf,address(inv));
        renderer.setSvg(0x61b62335,address(inv));
        renderer.setSvg(0x4a57010b,address(inv));
        renderer.setSvg(0x6a9597d8,address(inv));
        renderer.setSvg(0x8a931814,address(inv));
        renderer.setSvg(0xac0e7e72,address(inv));
        renderer.setSvg(0xab5427df,address(inv));
        renderer.setSvg(0x58599c53,address(inv));
        renderer.setSvg(0xde45c104,address(inv));
        renderer.setSvg(0xcd44b263,address(inv));
        renderer.setSvg(0x6b59c34d,address(inv));
        renderer.setSvg(0x956b2be9,address(inv));
        renderer.setSvg(0x6f6fbabb,address(inv));
        renderer.setSvg(0x20ce20a9,address(inv));
        renderer.setSvg(0xb3e6f4df,address(inv));
        renderer.setSvg(0x91453c32,address(inv));
        renderer.setSvg(0x0b2e5e3a,address(inv));
        renderer.setSvg(0x744b26f2,address(inv));
        renderer.setSvg(0xcd241afe,address(inv));
        renderer.setSvg(0x83e984d3,address(inv));
        renderer.setSvg(0xdbf751e2,address(inv));
        renderer.setSvg(0xa1f6dca5,address(inv));
        renderer.setSvg(0xdf657b4f,address(inv));
        renderer.setSvg(0xa4701ec8,address(inv));
        renderer.setSvg(0xdccaad8f,address(inv));
        renderer.setSvg(0x087a9ce2,address(inv));
        renderer.setSvg(0x49478d93,address(inv));
        renderer.setSvg(0xe85bffdd,address(inv));
        renderer.setSvg(0xfffed9b5,address(inv));
        renderer.setSvg(0x27bcb068,address(inv));
        renderer.setSvg(0x0ad0342c,address(inv));
        renderer.setSvg(0xf8c93061,address(inv));
        renderer.setSvg(0x5a93cb78,address(inv));
        renderer.setSvg(0x3858c2b3,address(inv));
        renderer.setSvg(0xca326b7f,address(inv));
        renderer.setSvg(0x16e3d678,address(inv));
        renderer.setSvg(0x073d371d,address(inv));
        renderer.setSvg(0x3b5540fd,address(inv));
        renderer.setSvg(0x885835a9,address(inv));
        renderer.setSvg(0x494ea23a,address(inv));
        renderer.setSvg(0xfdd7c247,address(inv));
        renderer.setSvg(0x5330dd45,address(inv));
        renderer.setSvg(0xf36fca32,address(inv));
        renderer.setSvg(0xf16569c4,address(inv));
        renderer.setSvg(0x304aa5f6,address(inv));
        renderer.setSvg(0xbada84bd,address(inv));
        renderer.setSvg(0x88e74a26,address(inv));
        renderer.setSvg(0x0321cb2e,address(inv));
        renderer.setSvg(0x8991e44d,address(inv));
        renderer.setSvg(0x430b8799,address(inv));
        renderer.setSvg(0x1661f7c2,address(inv));
        renderer.setSvg(0x33e17ed0,address(inv));
        renderer.setSvg(0xa84a76ff,address(inv));
        renderer.setSvg(0xb0db4b3d, address(inv));
        renderer.setSvg(0xe8f5f350, address(inv));
        renderer.setSvg(0xec86e745, address(inv));
        renderer.setSvg(0x3bce18fa, address(inv));
        renderer.setSvg(0x70ca8937, address(inv));
        renderer.setSvg(0xbcdc1492, address(inv));
        renderer.setSvg(0x139d690d, address(inv));
        renderer.setSvg(0x466f804d, address(inv));
        renderer.setSvg(0x8e5e6bcc, address(inv));
        renderer.setSvg(0x3ec70e91, address(inv));
        renderer.setSvg(0x9adeab98, address(inv));
        renderer.setSvg(0x497dcf60, address(inv));
        renderer.setSvg(0x82ab6bc8, address(inv));
        renderer.setSvg(0x5dca7a87, address(inv));
        renderer.setSvg(0xfa461972, address(inv));
        renderer.setSvg(0x2076854e, address(inv));
        renderer.setSvg(0x29bab4ce, address(inv));
        renderer.setSvg(0xcd38643b, address(inv));
        renderer.setSvg(0xdef49d6a, address(inv));
        renderer.setSvg(0xf09da6a3, address(inv));
        renderer.setSvg(0xaaceaf99, address(inv));
        renderer.setSvg(0x6bde659a, address(inv));
        renderer.setSvg(0x51c217da, address(inv));
        renderer.setSvg(0x8462f1c7, address(inv));
        renderer.setSvg(0x36375d8c, address(inv));
        renderer.setSvg(0x34eecfda, address(inv));
        renderer.setSvg(0x76499e75, address(inv));
        renderer.setSvg(0xee9b40ac, address(inv));
        renderer.setSvg(0x99ec87ed, address(inv));
        renderer.setSvg(0xcc10bc3a, address(inv));
        renderer.setSvg(0x7d4ccb8d, address(inv));
        renderer.setSvg(0x8c9e2c73, address(inv));
        renderer.setSvg(0x65b3de5f, address(inv));
        renderer.setSvg(0xad64fe83, address(inv));
        renderer.setSvg(0x6960ed76, address(inv));
        renderer.setSvg(0xb691a1a4, address(inv));
        renderer.setSvg(0x3eb4229e, address(inv));
        renderer.setSvg(0xab5271b7, address(inv));
        renderer.setSvg(0x3dae831b, address(inv));
        renderer.setSvg(0x7faf674b, address(inv));
        renderer.setSvg(0x7b5b7b91, address(inv));
        renderer.setSvg(0x30d71790, address(inv));
        renderer.setSvg(0xf59e6a1e, address(inv));
        renderer.setSvg(0x26b24f9f, address(inv));
        renderer.setSvg(0x29fc7a50, address(inv));
        renderer.setSvg(0x8597cce0, address(inv));
        renderer.setSvg(0x2b6e3483, address(inv));
        renderer.setSvg(0x8114f016, address(inv));
        renderer.setSvg(0x3828fd9d, address(inv));
        renderer.setSvg(0xb601e519, address(inv));
        renderer.setSvg(0xc6358593, address(inv));
        renderer.setSvg(0x82479f47, address(inv));
        renderer.setSvg(0xd0ad0ef6, address(inv));
        renderer.setSvg(0x8ccd9ce3, address(inv));
        renderer.setSvg(0x2aff2fd1, address(inv));
        renderer.setSvg(0x486c1d08, address(inv));
        renderer.setSvg(0x6212dc37, address(inv));
        renderer.setSvg(0x7ea99efb, address(inv));
        renderer.setSvg(0xb7ca43d3, address(inv));
        renderer.setSvg(0xc8b3e11f, address(inv));
        renderer.setSvg(0xf21c4372, address(inv));
        renderer.setSvg(0xe97a200b, address(inv));
        renderer.setSvg(0x96e9593a, address(inv));
        renderer.setSvg(0x29474283, address(inv));
        renderer.setSvg(0xcda4cd12, address(inv));
        renderer.setSvg(0x8c172b22, address(inv));
        renderer.setSvg(0x50f1089c, address(inv));
        renderer.setSvg(0x52fa3dc2, address(inv));
        renderer.setSvg(0x22e5b6d1, address(inv));
        renderer.setSvg(0xdfca2bae, address(inv));
        renderer.setSvg(0x29477089, address(inv));
        renderer.setSvg(0xc6fd1a76, address(inv));
        renderer.setSvg(0xb908ae4b, address(inv));
        renderer.setSvg(0x06c0ba3a, address(inv));
        renderer.setSvg(0x66d713d7, address(inv));
        renderer.setSvg(0x6de63982, address(inv));
        renderer.setSvg(0xa71d2004, address(inv));
        renderer.setSvg(0x07682fa4, address(inv));
        renderer.setSvg(0x0b88dff6, address(inv));
        renderer.setSvg(0x6f544441, address(inv));
        renderer.setSvg(0xb3892e1a, address(inv));
        renderer.setSvg(0xd4979825, address(inv));
        renderer.setSvg(0x43f0e120, address(inv));
        renderer.setSvg(0xd909a12a, address(inv));
        renderer.setSvg(0x6b3b961c, address(inv));
        renderer.setSvg(0x8c2eefd4, address(inv));
        renderer.setSvg(0xb36001dd, address(inv));
        renderer.setSvg(0x1bb8a211, address(inv));
        renderer.setSvg(0x39dd7f7c, address(inv));
        renderer.setSvg(0x48ad2d69, address(inv));
        renderer.setSvg(0xeed254a1, address(inv));
        renderer.setSvg(0x09e506e7, address(inv));
        renderer.setSvg(0x1a3c06a2, address(inv));
        renderer.setSvg(0x6f2b4984, address(inv));
        renderer.setSvg(0xa518456f, address(inv));
        renderer.setSvg(0x9f481107, address(inv));
        renderer.setSvg(0x4029ff08, address(inv));
        renderer.setSvg(0xd0f7c980, address(inv));
        renderer.setSvg(0x2d4ce4ae, address(inv));
        renderer.setSvg(0x27af5398, address(inv));
        renderer.setSvg(0x8f9ec61f, address(inv));
        renderer.setSvg(0x91566e71, address(inv));
        renderer.setSvg(0x0bc2bfa2, address(inv));
        renderer.setSvg(0xa34072c6, address(inv));
        renderer.setSvg(0xa0304f83, address(inv));
        renderer.setSvg(0x55874fda, address(inv));
        renderer.setSvg(0xce65da64, address(inv));
        renderer.setSvg(0x24d04e72, address(inv));
        renderer.setSvg(0x7f74bea7, address(inv));
        renderer.setSvg(0x16c1e8c4, address(inv));
        renderer.setSvg(0x9eb7d948, address(inv));
        renderer.setSvg(0xcf978ed8, address(inv));
        renderer.setSvg(0x0d11d484, address(inv));
        renderer.setSvg(0xec02c831, address(inv));
        renderer.setSvg(0xc04d5661, address(inv));
        renderer.setSvg(0x67ffc54c, address(inv));
        renderer.setSvg(0xf90bdf34, address(inv));
        renderer.setSvg(0x21a99b6e, address(inv));
        renderer.setSvg(0x87681b94, address(inv));
        renderer.setSvg(0x838280ad, address(inv));
        renderer.setSvg(0x97aac7d1, address(inv));
        renderer.setSvg(0xb96e4bda, address(inv));
        renderer.setSvg(0x18ce5e7c, address(inv));
        renderer.setSvg(0x29db3c91, address(inv));
        renderer.setSvg(0x56f498e5, address(inv));
        renderer.setSvg(0x19847317, address(inv));
        renderer.setSvg(0x85224a93, address(inv));
        renderer.setSvg(0x8a700bac, address(inv));
        renderer.setSvg(0x6524337f, address(inv));
        renderer.setSvg(0xe0b423d1, address(inv));
        renderer.setSvg(0x962d9819, address(inv));
        renderer.setSvg(0x6dd95606, address(inv));
        renderer.setSvg(0x14d473ae, address(inv));
        renderer.setSvg(0xafb93677, address(inv));
        renderer.setSvg(0xdd376b67, address(inv));
        renderer.setSvg(0x3cf97470, address(inv));
        renderer.setSvg(0x7f531b20, address(inv));
        renderer.setSvg(0x17a1f960, address(inv));
        renderer.setSvg(0x835804ba, address(inv));
        renderer.setSvg(0x569e4e6b, address(inv));
        renderer.setSvg(0xc2fd07b5, address(inv));
        renderer.setSvg(0x9a8d86b8, address(inv));
        renderer.setSvg(0x7a35e1bd, address(inv));
        renderer.setSvg(0x0ec67cf9, address(inv));
        renderer.setSvg(0x76223e3a, address(inv));
        renderer.setSvg(0xd0c4962a, address(inv));
        renderer.setSvg(0x52e897a0, address(inv));
        renderer.setSvg(0xacc620bb, address(inv));
        renderer.setSvg(0xfa6cb7d1, address(inv));
        renderer.setSvg(0x9fa1ef1d, address(inv));
        renderer.setSvg(0x64455304, address(inv));
        renderer.setSvg(0xe77c2190, address(inv));
        renderer.setSvg(0x43ad07ca, address(inv));
        renderer.setSvg(0xbe10311d, address(inv));
        renderer.setSvg(0xe7507bd5, address(inv));
        renderer.setSvg(0xceccc878, address(inv));
        renderer.setSvg(0x51979b55, address(inv));
        renderer.setSvg(0xb4eacd40, address(inv));
        renderer.setSvg(0x2df9d2f9, address(inv));
        renderer.setSvg(0x18883973, address(inv));
        renderer.setSvg(0x040f7660, address(inv));
        renderer.setSvg(0xbb00c32c, address(inv));
        renderer.setSvg(0xb23cd9b9, address(inv));
        renderer.setSvg(0xb5b70f3d, address(inv));
        renderer.setSvg(0x1d41a90e, address(inv));
        renderer.setSvg(0xbf71a7bc, address(inv));
        renderer.setSvg(0xf6fac0d2, address(inv));
        renderer.setSvg(0x53c265df, address(inv));
        renderer.setSvg(0x8903eb52, address(inv));
        renderer.setSvg(0x06b8d758, address(inv));
        renderer.setSvg(0xee50286d, address(inv));
        renderer.setSvg(0x8e4809ed, address(inv));
        renderer.setSvg(0xc480d30d, address(inv));
        renderer.setSvg(0xfd021fe8, address(inv));
        renderer.setSvg(0x90fc5885, address(inv));
        renderer.setSvg(0xcd77840a, address(inv));
        renderer.setSvg(0x055dcb3e, address(inv));
        renderer.setSvg(0x14ce9fa7, address(inv));
        renderer.setSvg(0xe5e50275, address(inv));
        renderer.setSvg(0x4eb0b59f, address(inv));
        renderer.setSvg(0x3a3add30, address(inv));
        renderer.setSvg(0x72d71d29, address(inv));
        renderer.setSvg(0x7f3ad859, address(inv));
        renderer.setSvg(0x92a3241f, address(inv));
        renderer.setSvg(0x354b47a8, address(inv));
        renderer.setSvg(0x3b01fa3d, address(inv));
        renderer.setSvg(0x0bf82ce2, address(inv));
        renderer.setSvg(0x71ef82b3, address(inv));
        renderer.setSvg(0x525e8c80, address(inv));
        renderer.setSvg(0x8ce904fe, address(inv));
        renderer.setSvg(0x3a789eef, address(inv));
        renderer.setSvg(0xe56a01cc, address(inv));
        renderer.setSvg(0x5c8bae9f, address(inv));
        renderer.setSvg(0x2258cbe2, address(inv));
        renderer.setSvg(0x570beedc, address(inv));
        renderer.setSvg(0x5e1b4f81, address(inv));
        renderer.setSvg(0x5450df67, address(inv));
        renderer.setSvg(0xd57e91b4, address(inv));
        renderer.setSvg(0x1f14ff6e, address(inv));
        renderer.setSvg(0xa044b49f, address(inv));
        renderer.setSvg(0xb48e2f84, address(inv));
        renderer.setSvg(0x1fd30fe3, address(inv));
        renderer.setSvg(0x7c1005d4, address(inv));
        renderer.setSvg(0x9ef48295, address(inv));
        renderer.setSvg(0xa744e595, address(inv));
        renderer.setSvg(0xd5dcaa31, address(inv));
        renderer.setSvg(0xdf467e94, address(inv));
        renderer.setSvg(0x13429c4d, address(inv));
        renderer.setSvg(0xe48a6474, address(inv));
        renderer.setSvg(0xc1706e50, address(inv));
        renderer.setSvg(0x1ec58496, address(inv));
        renderer.setSvg(0xf2fe8cdd, address(inv));
        renderer.setSvg(0x32634edb, address(inv));
        renderer.setSvg(0x3c5ca376, address(inv));
        renderer.setSvg(0xafd225e3, address(inv));
        renderer.setSvg(0x38a6c05a, address(inv));
        renderer.setSvg(0xe20bbf97, address(inv));
        renderer.setSvg(0x3f2cfa8a, address(inv));
        renderer.setSvg(0xa97bee15, address(inv));
        renderer.setSvg(0xaae999c3, address(inv));
        renderer.setSvg(0x1d08d0df, address(inv));
        renderer.setSvg(0xc5def7ba, address(inv));
        renderer.setSvg(0xc690e89d, address(inv));
        renderer.setSvg(0x9a588801, address(inv));
        renderer.setSvg(0x40d05c76, address(inv));
        renderer.setSvg(0xff12a97d, address(inv));
        renderer.setSvg(0x6b78d778, address(inv));
        renderer.setSvg(0xeee43c75, address(inv));
        renderer.setSvg(0x6912518c, address(inv));
        renderer.setSvg(0x54f2d11e, address(inv));
        renderer.setSvg(0x7d86785e, address(inv));
        renderer.setSvg(0xd1cc0753, address(inv));
        renderer.setSvg(0xa45889f9, address(inv));
    }
}
