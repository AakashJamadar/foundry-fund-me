// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testMsgSenderAddress() public view {
        // console.log(fundme.i_owner());
        // console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public view {
        // console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //expecting next line(transaction ig) to fail, if it doesn't expectRevert will fail.
        fundMe.fund();
    }

    function testFundUpdatesAmountFundedMapping() public {
        vm.prank(USER); // The next call(only) will be executed by this address
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The next call(only) will be executed by this address
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // Expecting next line(skips the line starting from "vm.") to be executed by this address
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawUsingSingleFunder() public funded {
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

    function testWithdrawUsingMultipleFunders() public {
        // Arrange
        uint160 startingIndex = 1;
        uint160 totalFunders = 10;

        for (uint160 i = startingIndex; i <= totalFunders; i++) {
            // vm.prank();
            // vm.deal(); Both cam be combined to make hoax
            hoax(address(i), SEND_VALUE); // Set msg.sender and give it ether for the next call
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner()); // Anything in between is pretended to be executed but the adderess given in prank
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingFundMeBalance + startingOwnerBalance);
    }

    function testWithdrawUsingMultipleFundersCheaper() public {
        // Arrange
        uint160 startingIndex = 1;
        uint160 totalFunders = 10;

        for (uint160 i = startingIndex; i <= totalFunders; i++) {
            // vm.prank();
            // vm.deal(); Both cam be combined to make hoax
            hoax(address(i), SEND_VALUE); // Set msg.sender and give it ether for the next call
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner()); // Anything in between is pretended to be executed but the adderess given in prank
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingFundMeBalance + startingOwnerBalance);
    }
}
