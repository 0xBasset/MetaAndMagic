// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../../modules/ds-test/src/test.sol";

import "../Stats.sol";

contract GasTests is DSTest {

    enum Stat { HP, PHY_DMG, MGK_DMG, MGK_RES, MGK_PEN, PHY_RES, PHY_PEN, ELM }

    // function test_gas_statsRetrieval() external {
    //     AttackItemsStats st = new AttackItemsStats();


    //     uint256[6] memory tra = [uint256(2),2,2,2,2,2]; 

    //     uint firstGas = gasleft();
    //     (bytes32 s1, bytes32 s2) = st.getStats(tra);
    //     uint256 st1 = _get(s1, Stat.HP, 0);
    //     uint256 secGas = gasleft();
    //     emit log_named_uint("diff", firstGas - secGas);

    //     firstGas = gasleft();
    //     bytes10[6] memory b = st.getStatsArri(tra);
    //     uint256 st2 = _get(b[0], Stat.HP, 0);
    //     secGas = gasleft();
    //     emit log_named_uint("diff", firstGas - secGas);
    // }

    // function _get(bytes32 src, Stat sta, uint256 index) internal pure returns (uint256) {
    //     uint8 st = uint8(sta);

    //     if (st == 7) return uint64(uint256(src)); // Element
        
    //     bytes8 att = bytes8((src) << (index * 64));

    //     if (st < 3)  return uint16(bytes2(att << (st * 16))); // Hp, PhyDmg or MgkDmg

    //     return (uint16(bytes2(att << (48))) & (1 << st - 3)) >> st - 3;
    // }
    
}
