// SPDX-License-Identifier: UNLIMITCENSED
pragma solidity 0.8.7;

import "../modules/ds-test/src/test.sol";

import "./utils/Mocks.sol";

import "./utils/MockMetaAndMagic.sol";

import "./utils/MockERC20.sol";

import "./utils/Interfaces.sol";

import "../contracts/Proxy.sol";


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

        meta.setUpOracle(address(oracle), bytes32(0), uint64(1));

        meta.initialize(address(heroes), address(items));
        
        heroes.initialize(address(new HeroStats()), address(0));
        heroes.setEntropy(uint256(keccak256(abi.encode("HEROES_NTROPY"))));
        heroes.setAuth(address(meta), true);
        heroes.setAuth(address(this), true);

        // Set up items
        items.initialize(address(new AttackItemsStats()), address(new DefenseItemsStats()), address(new SpellItemsStats()), address(new BuffItemsStats()), address(new BossDropsStats()), address(0));
        items.setEntropy(uint256(keccak256(abi.encode("ITEMS_ENTROPY"))));
        items.setAuth(address(meta), true);
        items.setAuth(address(this), true);
    }

    // Helper Functions
    function _getPackedItems(uint16[5] memory items_) internal pure returns(bytes10 packed) {
        packed = bytes10(abi.encodePacked(items_[0], items_[1], items_[2], items_[3], items_[4]));
    }

    function _addBoss() internal {
        meta.addBoss(address(1), 100e18, 10000, 1000, 1000, 3, 0);
    }

    function _addBoss(address token, uint256 amt) internal {
        meta.addBoss(address(token), amt, 10000, 1000, 1000, 3, 0);
    }

}

contract AddBossTest is MetaAndMagicBaseTest {

    function test_AddBoss(address prizeToken, uint256 halfPrize, uint16 hp_, uint16 atk_, uint16 mgk_, uint8 mod_, uint8 ele) public {
        meta.addBoss(prizeToken, halfPrize, hp_, atk_, mgk_, mod_, ele);

        assertEq(meta.prizeTokens(1), prizeToken);
        assertEq(meta.prizeValues(1), halfPrize);

        (, uint16 top, uint128 hs,,)= meta.bosses(1);

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
        if (one != 0) items.mintId(address(this), one);
        if (two != 0) items.mintId(address(this), two);
        if (three != 0) items.mintId(address(this), three);
        if (four != 0) items.mintId(address(this), four);
        if (five != 0) items.mintId(address(this), five);
        list = [one, two, three, four, five];
    }

}

contract StakeTest is MetaAndMagicBaseTest {

    function testStake_success() external {
        _addBoss();

        uint256 heroId = heroes.mint(address(this), 1);

        meta.stake(heroId);

        (address owner, uint16 lastBoss, uint32 highestScore) = meta.heroes(heroId);
        assertEq(owner, address(this));
        assertEq(lastBoss, 0);
        assertEq(highestScore, 0);
    }

    function testStake_failIfNotStarted() external {
        uint256 heroId = heroes.mint(address(this), 1);

        vm.expectRevert("not started");
        meta.stake(heroId);
    }

    function testStake_canUnstake() external {
        uint256 heroId = heroes.mint(address(this), 1);
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

    function testStake_failWithNotOwner() external {
        uint256 heroId = heroes.mint(address(this), 1);

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

    function testStake_failIfFought() external {
        uint256 heroId = heroes.mint(address(this), 1);

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

    uint256 boss   = 1;
    uint256 heroId = 1;

    uint16[5] list; 

    bytes10 itm;
    bytes10 itm2;

    bytes8  bossStats = 0x0009000900090000;

    function setUp() public override {
        super.setUp();
        _addBoss();
        meta.setBossStats(boss, bossStats);

        heroes.mint(address(this), heroId);
        heroes.approve(address(meta), heroId);

        meta.stake(heroId);

        list = items.mintFive(address(this), 5, 4, 3, 2, 1);

        list = [5,0,0,0,0];
        itm  = _getPackedItems(list);

        list = [5,4,3,2,1];
        itm2 = _getPackedItems(list);
    }

    function test_fight_success() external {
        uint256 score = meta.getScore(boss, bossStats, heroId, itm);
        bytes32 id    = meta.fight(heroId, itm);

       (uint256 hero, uint256 boss_, bytes10 items_, uint256 start, uint256 count, bool scoreClaimed , bool bossClaimed ) = meta.fights(id);

        assertEq(hero,    heroId);
        assertEq(boss_,   boss);
        assertEq(items_ , itm);
        assertEq(start,   1);
        assertEq(count,   score);
        
        assertTrue(!scoreClaimed);
        assertTrue(!bossClaimed);

        (,uint16 topS,uint128 hs, uint256 entries, uint256 winningIndex) = meta.bosses(boss);
        
        assertEq(score, hs);
        assertEq(topS, 1);
        assertEq(entries, score);
        assertEq(winningIndex, 0);
    }
    
    function test_fight_replaceHeroHighScore() external {
        uint256 score1 = meta.getScore(boss, bossStats, heroId, itm);
        bytes32 id     = meta.fight(heroId, itm);

        ( , , , uint32 start, uint32 count, , ) = meta.fights(id);

        assertEq(start, 1);
        assertEq(count, score1);

        uint256 score2 = meta.getScore(boss, bossStats, heroId, itm2);
        bytes32 id2    = meta.fight(heroId, itm2);

        ( , , , start, count,,) = meta.fights(id2);

        assertEq(start, score1 + 1);
        assertEq(count, score2 - score1);
 
        (,uint256 top ,uint256 hs,uint256 entries,  uint256 winningIndex) = meta.bosses(boss);
        assertEq(hs, score2);
        assertEq(top, 1);
        assertEq(entries, score2);
        assertEq(winningIndex, 0);
    }

    function test_fight_failTwice() external { 
        meta.fight(heroId, itm);

        vm.expectRevert(bytes("already fought"));
        meta.fight(heroId, itm);
    }

}

contract ClaimBossDropTest is MetaAndMagicBaseTest {
    uint256 boss   = 1;
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

        uint256 score = meta.getScore(boss, bossStats, heroId, itm);

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

        uint256 score = meta.getScore(boss, bossStats, heroId, itm);

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

        uint256 score = meta.getScore(boss, bossStats, heroId, itm);

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

        uint256 score = meta.getScore(boss,bossStats, heroId, itm);

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

contract GetRaffleResult is MetaAndMagicBaseTest {
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

    function test_getRaffle_sucess(uint56 entries) external {
        if (entries == 0) entries++;

        meta.setBossEntries(1, entries);

        // Move to boss 2
        _addBoss();

        meta.requestRaffleResult(boss);

        assertTrue(meta.requests(boss) != 0);

        oracle.fulfill();

        (,,, uint256 entries_, uint256 winInd) = meta.bosses(boss);

        assertEq(entries_, entries);
        assertTrue(winInd != 0);
        assertTrue(winInd <= entries);
    } 

    function test_getRaffle_FailFOrCurrentBoss() external {
        vm.expectRevert("not finished");
        meta.requestRaffleResult(boss);
    } 

    function test_getRaffle_FailClaimTwice(uint56 entries) external {
        if (entries == 0) entries++;

        meta.setBossEntries(1, entries);

        // Move to boss 2
        _addBoss();

        meta.requestRaffleResult(boss);

        assertTrue(meta.requests(boss) != 0);

        vm.expectRevert("already requested");
        meta.requestRaffleResult(boss);
    } 
}

contract GetStatsTest is MetaAndMagicBaseTest {

    function setUp() public override {
        super.setUp();
    }

    function test_get_attributes() public {
        // Traits for hero 1: [4,7,3,1,1,0]

        bytes10[6] memory stats = heroes.getStats(1);

        //Level (V) atts
        assertEq(meta.get(stats[0],0), 396); // hp
        assertEq(meta.get(stats[0],1), 0);   // atk
        assertEq(meta.get(stats[0],2), 0);   //mgk
        assertEq(meta.get(stats[0],3), 0);   // mgk_res
        assertEq(meta.get(stats[0],4), 0);   // mgk_pem
        assertEq(meta.get(stats[0],5), 0);   // phy_res
        assertEq(meta.get(stats[0],6), 0);   // phy_pen

        // Class (Mage) atts
        assertEq(meta.get(stats[1],0), 4000); // hp
        assertEq(meta.get(stats[1],1), 2000);   // atk
        assertEq(meta.get(stats[1],2), 2000);   //mgk
        assertEq(meta.get(stats[1],3), 1);   // mgk_res
        assertEq(meta.get(stats[1],4), 1);   // mgk_pem
        assertEq(meta.get(stats[1],5), 1);   // phy_res
        assertEq(meta.get(stats[1],6), 1);   // phy_pen

        // // Rank (novice) atts
        // assertEq(meta.get(s1,0,2), 99); // hp
        // assertEq(meta.get(s1,1,2), 0);   // atk
        // assertEq(meta.get(s1,2,2), 0);   //mgk
        // assertEq(meta.get(s1,3,2), 0);   // mgk_res
        // assertEq(meta.get(s1,4,2), 0);   // mgk_pem
        // assertEq(meta.get(s1,5,2), 0);   // phy_res
        // assertEq(meta.get(s1,6,2), 0);   // phy_pen

        // // Rarity (epic) atts
        // assertEq(meta.get(s2,0,0), 500); // hp
        // assertEq(meta.get(s2,1,0), 500);   // atk
        // assertEq(meta.get(s2,2,0), 500);   //mgk
        // assertEq(meta.get(s2,3,0), 1);   // mgk_res
        // assertEq(meta.get(s2,4,0), 0);   // mgk_pem
        // assertEq(meta.get(s2,5,0), 1);   // phy_res
        // assertEq(meta.get(s2,6,0), 1);   // phy_pen

        // // Pet (Sphinx) atts
        // assertEq(meta.get(s2,0,1), 4000); // hp
        // assertEq(meta.get(s2,1,1), 4000); // atk
        // assertEq(meta.get(s2,2,1), 4000);   //mgk
        // assertEq(meta.get(s2,3,1), 1);   // mgk_res
        // assertEq(meta.get(s2,4,1), 1);   // mgk_pem
        // assertEq(meta.get(s2,5,1), 1);   // phy_res
        // assertEq(meta.get(s2,6,1), 1);   // phy_pen

        // // Item (elixir) atts
        // assertEq(meta.get(s2,0,2), 1500); // hp
        // assertEq(meta.get(s2,1,2), 0);    // atk
        // assertEq(meta.get(s2,2,2), 0);    //mgk
        // assertEq(meta.get(s2,3,2), 0);    // mgk_res
        // assertEq(meta.get(s2,4,2), 0);    // mgk_pem
        // assertEq(meta.get(s2,5,2), 1);    // phy_res
        // assertEq(meta.get(s2,6,2), 0);    // phy_pen
    }
    
}
