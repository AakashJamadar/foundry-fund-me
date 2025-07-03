// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.01 ether;
    address USER = makeAddr("user");
    

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view{
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFunctionFail() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunderFromIndex(0), USER);
    }
    
    function testAddressToAmountFunded() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAmountFromMapping(USER), SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawFunctionFailing() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawByOwner() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);

        assertEq(endingOwnerBalance, startingFundMeBalance + startingOwnerBalance);
    }

    function testWithdrawAfterMultipleFundersCheaper() public funded {
        // Arrange
        uint160 totalFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= totalFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert 
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingFundMeBalance+ startingOwnerBalance);
    }

    function testWithdrawAfterMultipleFunders() public funded {
        // Arrange
        uint160 totalFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= totalFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert 
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingFundMeBalance+ startingOwnerBalance);
    }
}
