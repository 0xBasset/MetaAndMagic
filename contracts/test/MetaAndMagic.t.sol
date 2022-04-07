// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../../modules/ds-test/src/test.sol";

import "./utils/Mocks.sol";

import "./utils/MockERC20.sol";

import "./utils/Interfaces.sol";

import "../Proxy.sol";


contract MetaAndMagicBaseTest is DSTest {
    MockMetaAndMagic meta;
    HeroesMock       heroes;
    ItemsMock        items;
    VRFMock          oracle;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public virtual {

        heroes = HeroesMock(address(new Proxy(address(new HeroesMock()))));
        items  = ItemsMock(address(new Proxy(address(new ItemsMock()))));
        meta   = MockMetaAndMagic(address(new Proxy(address(new MockMetaAndMagic()))));
        oracle = new VRFMock();

        meta.initialize(address(heroes), address(items));
        
        
        heroes.initialize(address(new HeroStats()), address(0));
        heroes.setEntropy(uint256(keccak256(abi.encode("HEROES_NTROPY"))));
        heroes.setAuth(address(meta), true);

        // Set up items
        items.initialize(address(new AttackItemsStats()), address(new DefenseItemsStats()), address(new SpellItemsStats()), address(new BuffItemsStats()), address(new BossDropsStats()), address(0));
        items.setEntropy(uint256(keccak256(abi.encode("ITEMS_ENTROPY"))));
        items.setAuth(address(meta), true);
    }

    // Helper Functions
    function _getPackedItems(uint16[5] memory items_) internal pure returns(bytes10 packed) {
        packed = bytes10(abi.encodePacked(items_[0], items_[1], items_[2], items_[3], items_[4]));
    }

    function _addBoss() internal {
        meta.addBoss(address(1), 100e18, 20, 10000, 1000, 1000, 3, 0);
    }

    function _addBoss(address token, uint256 amt) internal {
        meta.addBoss(address(token), amt, 20, 10000, 1000, 1000, 3, 0);
    }

}

contract AddBossTest is MetaAndMagicBaseTest {

    function test_AddBoss(address prizeToken, uint256 halfPrize, uint16 drops, uint16 hp_, uint16 atk_, uint16 mgk_, uint8 mod_, uint8 ele) public {
        meta.addBoss(prizeToken, halfPrize, drops, hp_, atk_, mgk_, mod_, ele);

        assertEq(meta.prizeTokens(2), prizeToken);
        assertEq(meta.prizeValues(2), halfPrize);

        (, uint16 d, uint16 top, uint128 hs,,)= meta.bosses(2);

        assertEq(d, drops);
        assertEq(hs, 0);
        assertEq(top, 0);
    }
    
}

contract ValidateItemTest is MetaAndMagicBaseTest {

    function test_validateItems_CorrectOrder() external {
        uint16[5] memory items_ = [uint16(1), 1, 1, 1, 1];

        // Valid lists
        items_ = _mintItems(342, 212, 111, 90, 3);
        meta.validateItems(items_);

        items_ = _mintItems(333, 120, 0, 0, 0);
        meta.validateItems(items_);

        items_ = _mintItems(300, 0, 0, 0, 0);
        meta.validateItems(items_);

        items_ = _mintItems(1, 0, 0, 0, 0);
        meta.validateItems(items_);
    }

    function test_validateItems_InvalidItems() external {
        uint16[5] memory items_ = [uint16(1), 1, 1, 1, 1];

        // Invalid Orders
        items_ = _mintItems(342, 212, 311, 0, 0);
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);

        items_ = _mintItems(343, 213, 313, 0, 3);
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);

        items_ = _mintItems(1, 200, 111, 0, 5);
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);

        items_ = _mintItems(0, 0, 0, 0, 0);
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);

        items_ = _mintItems(1000, 0, 444, 333, 141);
        items_ = [1000,1000,444,333,141];
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);

        items_ = _mintItems(999, 0, 555, 666, 181);
        items_ = [999,666,555,181,181];
        vm.expectRevert(bytes("invalid items"));
        meta.validateItems(items_);
    }

    function test_validateItems_NotOwner() external {
        uint16[5] memory items_ = [uint16(1), 1, 1, 1, 1];

        items_ = _mintItems(342, 212, 111, 90, 3);
        items_ = [342, 212, 111, 90, 4];
        vm.expectRevert(bytes("not item owner"));
        meta.validateItems(items_);
    }

    function _mintItems(uint16 one, uint16 two, uint16 three, uint16 four, uint16 five) internal returns (uint16[5] memory list) {
        if (one != 0) items.mint(address(this), one);
        if (two != 0) items.mint(address(this), two);
        if (three != 0) items.mint(address(this), three);
        if (four != 0) items.mint(address(this), four);
        if (five != 0) items.mint(address(this), five);
        list = [one, two, three, four, five];
    }

}

contract StakeTest is MetaAndMagicBaseTest {

    function testStake_success(uint16 heroId) external {
        if (heroId == 0) heroId++;

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);

        (address owner, uint16 lastBoss, uint32 highestScore) = meta.heroes(heroId);
        assertEq(owner, address(this));
        assertEq(lastBoss, 0);
        assertEq(highestScore, 0);
    }

    function testStake_notApproved(uint16 heroId) external {
        heroes.mint(address(this), heroId);

        vm.expectRevert(bytes("NOT_APPROVED"));
        meta.stake(heroId);

        heroes.approve(address(meta), heroId);
        meta.stake(heroId);
    }

    function _testStake_canUnstake(uint16 heroId) external {
        _addBoss();

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);

        // Not fighted so allowed to unstake
        meta.unstake(heroId);   
        (address owner, uint16 lastBoss, uint32 highestScore) = meta.heroes(heroId);
        assertEq(owner, address(0));
        assertEq(lastBoss, 0);
        assertEq(highestScore, 0);     
    }    

    function _testStake_failWithNotOwner(uint16 heroId) external {
        _addBoss();

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);

        // Not fighted so allowed to unstake
        vm.prank(address(2));
        vm.expectRevert("not owner");
        meta.unstake(heroId);   

        meta.unstake(heroId); 
        (address owner, uint16 lastBoss, uint32 highestScore) = meta.heroes(heroId);
        assertEq(owner, address(0));
        assertEq(lastBoss, 0);
        assertEq(highestScore, 0);     
    }    

    function _testStake_failIfFought(uint16 heroId) external {
        _addBoss();

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);

        uint16[5] memory list = items.mintFive(address(this), 5, 4, 3, 2, 1);
        bytes10 itm = _getPackedItems(list);

        meta.fight(heroId, itm);
        
        // Not fighted so allowed to unstake
        vm.expectRevert("alredy entered");
        meta.unstake(heroId);   

        _addBoss();

        meta.unstake(heroId); 
        (address owner, uint16 lastBoss, uint32 highestScore) = meta.heroes(heroId);
        assertEq(owner, address(0));
        assertEq(lastBoss, 0);
        assertEq(highestScore, 0);     
    }    

}

contract FightTest is MetaAndMagicBaseTest {

    uint256 boss   = 2;
    uint256 heroId = 1;

    uint16[5] list; 
    uint16[5] list2; 

    bytes10 itm;
    bytes10 itm2;

    function setUp() public override {
        super.setUp();
        _addBoss();

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);
        list = items.mintFive(address(this), 5, 4, 3, 2, 1);
        itm = _getPackedItems(list);

        list2 = items.mintFive(address(this), 10, 9, 8, 7, 6);
        itm2 = _getPackedItems(list2);
    }

    function test_fight_success() external {
        bytes32 id = meta.fight(heroId, itm);

       (uint256 hero, uint256 boss_, bytes10 items_, uint256 start, uint256 count, bool scoreClaimed , bool bossClaimed ) = meta.fights(id);

        assertEq(hero, heroId);
        assertEq(boss_, boss);
        assertEq(items_ , itm);
        assertEq(start, 1);
        assertEq(count, 10);
        
        assertTrue(!scoreClaimed);
        assertTrue(!bossClaimed);

        uint256 score = meta.getScore(boss, heroId, itm);

        (,,uint16 topS,uint128 hs,uint256 entries, uint256 winningIndex) = meta.bosses(boss);
        
        assertEq(score, hs);
        // assertEq(score, nextScore);
        assertEq(topS, 1);
        // assertEq(entries, nextScore);
        assertEq(winningIndex, 0);
    }
    
    function test_fight_replaceHeroHighScore() external {
        bytes32 id = meta.fight(heroId, itm);

        ( , , , uint32 start, uint32 count, , ) = meta.fights(id);

        assertEq(start, 1);
        assertEq(count, 10);

        uint256 secondScore = 14;
        // meta.setNextScore(secondScore);

        bytes32 id2 = meta.fight(heroId, itm2);

        ( , , , start, count,,) = meta.fights(id2);

        assertEq(start, 11);
        assertEq(count, 4);
 
        (,, uint256 top ,uint256 hs,uint256 entries,  uint256 winningIndex) = meta.bosses(boss);
        assertEq(hs, secondScore);
        assertEq(top, 1);
        assertEq(entries, 14);
        assertEq(winningIndex, 0);
    }

    function test_fight_topScores() external {

        uint256 tops = 25;
        for (uint16 i = 2; i < tops; i++) {
            // mint hero
            heroes.mint(address(this), i);
            heroes.approve(address(meta), i); 

            uint16[5] memory deck = items.mintFive(address(this), i * 100 + i, i * 90 + i, i * 80 + i, i * 70 + i, i * 60+ i);
            bytes10 d = _getPackedItems(deck);
            
            meta.stake(i);   
            meta.fight(i, d);
        }

        (,, uint256 top ,uint256 hs,uint256 entries,  uint256 winningIndex) = meta.bosses(boss);

        assertEq(hs, 10);
        assertEq(top, tops - 2);
        assertEq(entries, (tops - 2) * 10);
        assertEq(winningIndex, 0);
    }

    function test_fight_replaceBossHighScore() external {

        uint256 tops = 25;
        for (uint16 i = 2; i < tops; i++) {
            // mint hero
            heroes.mint(address(this), i);
            heroes.approve(address(meta), i); 

            uint16[5] memory deck = items.mintFive(address(this), i * 100 + i, i * 90 + i, i * 80 + i, i * 70 + i, i * 60+ i);
            bytes10 d = _getPackedItems(deck);
            
            meta.stake(i);   
            meta.fight(i, d);
        }

        (,, uint256 top ,uint256 hs,,uint256 winningIndex) = meta.bosses(boss);
        assertEq(hs, 24 * 100);
        assertEq(top, 1);
        assertEq(winningIndex, 0);
    }

    function test_fight_failTwice() external { 
        meta.fight(heroId, itm);

        vm.expectRevert(bytes("already fought"));
        meta.fight(heroId, itm);
    }

}

contract ClaimBossDropTest is MetaAndMagicBaseTest {
    uint256 boss   = 2;
    uint256 heroId = 1;

    uint16[5] list = [5,4,3,2,1];  
    bytes10 itm;

    bytes32 fightId;

    function setUp() public override {
        super.setUp();
        _addBoss();

        itm = _getPackedItems(list);

        fightId = meta.getFightId(heroId, boss, itm, address(this));

        meta.setFight(fightId, heroId, boss, itm, 0, 0, false, false);
    }

    function test_claimBossDrop_success() external {
        uint256 itemId = meta.getBossDrop(heroId, boss, itm);

        assertEq(items.ownerOf(itemId), address(this));

        // Check all items are burned
        for (uint256 i = 0; i < list.length; i++) {
            assertEq(items.ownerOf(list[i]), address(0));
        }

        (,,,,,, bool bossClaimed) = meta.fights(fightId);
        assertTrue(bossClaimed);
    }

    function test_claimBossDrop_failWithClaimTwice() external {
        uint256 itemId = meta.getBossDrop(heroId, boss, itm);

        assertEq(items.ownerOf(itemId), address(this));

        // Check all items are burned
        for (uint256 i = 0; i < list.length; i++) {
            assertEq(items.ownerOf(list[i]), address(0));
        }

        vm.expectRevert("already claimed");
        meta.getBossDrop(heroId, boss, itm);
    }     

    function test_claimBossDrop_failForInvalidFight() external {
        vm.expectRevert("non existent fight");
        meta.getBossDrop(heroId + 1, boss, itm);
    }

    function test_claimBossDrop_failFightNotWon() external {
        // Setting OP boss
        meta.setBossStats(boss, 0xffffffffffff0000);

        vm.expectRevert("not won");
        meta.getBossDrop(heroId, boss, itm);
    }

}

contract ClaimHighestScoreTest is MetaAndMagicBaseTest {

    uint256 boss   = 1;
    uint256 heroId = 1;

    uint256 prize = 100e18;

    uint16[5] list = [5,4,3,2,1];  
    bytes10 itm;

    bytes8 bossStats = 0x0001000100010000;

    bytes32 fightId;

    MockERC20 token;

    function setUp() public override {
        super.setUp();

        token = new MockERC20();

        _addBoss(address(token), prize);

        itm = _getPackedItems(list);

        fightId = meta.getFightId(heroId, boss, itm, address(this));


        meta.setFight(fightId, heroId, boss, itm, 0, 0, false, false);
    }

    function test_claimHSDrop_failIfNotFinished() external {
        vm.expectRevert("not finished");
        meta.getPrize(heroId, boss, itm);
    }

    function test_claimHSDrop_success() external {
        _addBoss();

        uint256 score = meta.getScore(bossStats, heroId, itm);

        meta.setBossStats(boss, bossStats);
        meta.setBossHighScore(boss, score, 1);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getPrize(heroId, boss, itm);

        (,,,,,bool hsClaimed,) = meta.fights(fightId);
        assertTrue(hsClaimed);

        assertEq(token.balanceOf(address(this)), initBal + prize);
    }

    function test_claimHSDrop_failAlreadyClaimed() external {
        _addBoss();

        uint256 score = meta.getScore(bossStats, heroId, itm);

        meta.setBossStats(boss, bossStats);
        meta.setBossHighScore(boss, score, 1);

        token.mint(address(meta), 400e18);

        meta.getPrize(heroId, boss, itm);

        (,,,,,bool hsClaimed,) = meta.fights(fightId);
        assertTrue(hsClaimed);

        vm.expectRevert("already claimed");
        meta.getPrize(heroId, boss, itm);
    }  

    function test_claimHSDrop_failWrongHS() external {
        _addBoss();

        uint256 score = meta.getScore(bossStats, heroId, itm);

        meta.setBossStats(boss, bossStats);
        meta.setBossHighScore(boss, score +1, 1);

        token.mint(address(meta), 400e18);

        vm.expectRevert("not high score");
        meta.getPrize(heroId, boss, itm);
    }  

    function test_claimHSDrop_failIfZeroHS() external {
        _addBoss();

        meta.setBossStats(boss, 0xffffffffffff0000);
        meta.setBossHighScore(boss, 0, 1);

        token.mint(address(meta), 400e18);

        vm.expectRevert("not high score");
        meta.getPrize(heroId, boss, itm);
    }  

    function test_claimHSDrop_successSplittingPrize() external {
        _addBoss();

        uint256 score = meta.getScore(bossStats, heroId, itm);

        meta.setBossStats(boss, bossStats);
        meta.setBossHighScore(boss, score, 16);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getPrize(heroId, boss, itm);

        (,,,,,bool hsClaimed,) = meta.fights(fightId);
        assertTrue(hsClaimed);

        assertEq(token.balanceOf(address(this)), initBal + (prize / 16));
    }

}

contract ClaimRaffleTest is MetaAndMagicBaseTest {

    uint256 boss   = 1;
    uint256 heroId = 1;

    uint256 prize = 100e18;

    uint16[5] list = [5,4,3,2,1];  
    bytes10 itm;

    bytes8 bossStats = 0x0001000100010000;

    bytes32 fightId;

    MockERC20 token;

    function setUp() public override {
        super.setUp();

        token = new MockERC20();

        _addBoss(address(token), prize);

        itm = _getPackedItems(list);

        fightId = meta.getFightId(heroId, boss, itm, address(this));
        
    }

    function test_claimRaffle_failIfNotFinished() external {
        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        vm.expectRevert("not finished");
        meta.getRafflePrize(heroId, boss, itm);
    }

    function test_claimRaffle_successMiddle() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        meta.setBossHighScore(boss, 1, 1);
        meta.setBosswinIndex(boss, 25);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getRafflePrize(heroId, boss, itm);

        assertEq(token.balanceOf(address(this)), initBal + prize);
    }

    function test_claimRaffle_successFirstIndex() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 25, 20, false, false);

        meta.setBossHighScore(boss, 1, 1);
        meta.setBosswinIndex(boss, 25);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getRafflePrize(heroId, boss, itm);

        assertEq(token.balanceOf(address(this)), initBal + prize);
    }

    function test_claimRaffle_successLastIndex() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        meta.setBossHighScore(boss, 1, 1);
        meta.setBosswinIndex(boss, 41);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getRafflePrize(heroId, boss, itm);

        assertEq(token.balanceOf(address(this)), initBal + prize);
    }

    function test_claimRaffle_failAlreadyClaimed() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        meta.setBossHighScore(boss, 1, 1);
        meta.setBosswinIndex(boss, 22);

        token.mint(address(meta), 200e18);

        uint256 initBal = token.balanceOf(address(this));

        meta.getRafflePrize(heroId, boss, itm);

        assertEq(token.balanceOf(address(this)), initBal + prize);

        vm.expectRevert("not winner");
        meta.getRafflePrize(heroId, boss, itm);
    }  

    function test_claimRaffle_failWrongHS() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        meta.setBossHighScore(boss, 0, 1);
        meta.setBosswinIndex(boss, 25);

        token.mint(address(meta), 200e18);

        vm.expectRevert("not fought");
        meta.getRafflePrize(heroId, boss, itm);
    }  

    function test_claimRaffle_failNotRaffled() external {
        _addBoss();

        meta.setFight(fightId, heroId, boss, itm, 22, 20, false, false);

        meta.setBossHighScore(boss, 1, 1);
        meta.setBosswinIndex(boss, 0);

        token.mint(address(meta), 200e18);

        vm.expectRevert("not raffled");
        meta.getRafflePrize(heroId, boss, itm);
    }  
}

// contract GetStatsTest is MetaAndMagicBaseTest {

//     function setUp() public override {
//         super.setUp();
//     }

//     function test_get_attributes() public {
//         heroes.setAttributes(1, [uint256(5),5,1,5,4,15]);

//         (bytes32 s1, bytes32 s2) = heroes.getStats(1);

//         assertTrue(s1 != bytes32(0));
//         assertTrue(s2 != bytes32(0));

//         //Level (V) atts
//         assertEq(meta.get(s1,0,0), 500); // hp
//         assertEq(meta.get(s1,1,0), 0);   // atk
//         assertEq(meta.get(s1,2,0), 0);   //mgk
//         assertEq(meta.get(s1,3,0), 0);   // mgk_res
//         assertEq(meta.get(s1,4,0), 0);   // mgk_pem
//         assertEq(meta.get(s1,5,0), 0);   // phy_res
//         assertEq(meta.get(s1,6,0), 0);   // phy_pen

//         // Class (Mage) atts
//         assertEq(meta.get(s1,0,1), 1000); // hp
//         assertEq(meta.get(s1,1,1), 0);   // atk
//         assertEq(meta.get(s1,2,1), 1000);   //mgk
//         assertEq(meta.get(s1,3,1), 1);   // mgk_res
//         assertEq(meta.get(s1,4,1), 1);   // mgk_pem
//         assertEq(meta.get(s1,5,1), 0);   // phy_res
//         assertEq(meta.get(s1,6,1), 0);   // phy_pen

//         // Rank (novice) atts
//         assertEq(meta.get(s1,0,2), 99); // hp
//         assertEq(meta.get(s1,1,2), 0);   // atk
//         assertEq(meta.get(s1,2,2), 0);   //mgk
//         assertEq(meta.get(s1,3,2), 0);   // mgk_res
//         assertEq(meta.get(s1,4,2), 0);   // mgk_pem
//         assertEq(meta.get(s1,5,2), 0);   // phy_res
//         assertEq(meta.get(s1,6,2), 0);   // phy_pen

//         // Rarity (epic) atts
//         assertEq(meta.get(s2,0,0), 500); // hp
//         assertEq(meta.get(s2,1,0), 500);   // atk
//         assertEq(meta.get(s2,2,0), 500);   //mgk
//         assertEq(meta.get(s2,3,0), 1);   // mgk_res
//         assertEq(meta.get(s2,4,0), 0);   // mgk_pem
//         assertEq(meta.get(s2,5,0), 1);   // phy_res
//         assertEq(meta.get(s2,6,0), 1);   // phy_pen

//         // Pet (Sphinx) atts
//         assertEq(meta.get(s2,0,1), 4000); // hp
//         assertEq(meta.get(s2,1,1), 4000); // atk
//         assertEq(meta.get(s2,2,1), 4000);   //mgk
//         assertEq(meta.get(s2,3,1), 1);   // mgk_res
//         assertEq(meta.get(s2,4,1), 1);   // mgk_pem
//         assertEq(meta.get(s2,5,1), 1);   // phy_res
//         assertEq(meta.get(s2,6,1), 1);   // phy_pen

//         // Item (elixir) atts
//         assertEq(meta.get(s2,0,2), 1500); // hp
//         assertEq(meta.get(s2,1,2), 0);    // atk
//         assertEq(meta.get(s2,2,2), 0);    //mgk
//         assertEq(meta.get(s2,3,2), 0);    // mgk_res
//         assertEq(meta.get(s2,4,2), 0);    // mgk_pem
//         assertEq(meta.get(s2,5,2), 1);    // phy_res
//         assertEq(meta.get(s2,6,2), 0);    // phy_pen
//     }
    
// }
