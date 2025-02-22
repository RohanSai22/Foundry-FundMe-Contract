// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";

import {FundMe} from "src/FundMe.sol";

import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 num = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_AMOUNT = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 2;

    //FundMe fundMe1 = new FundMe(); [also passed]

    //at first our setup function is run before anything else
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_BALANCE);
    }

    function testMinDollar() public view {
        // FundMe fundMe = new FundMe();
        // fundMe.getVersion();
        //console.log("testDemo",num);
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function owner() public view {
        assertEq(fundMe.i_owner(), msg.sender); //[works]
        assertEq(fundMe.getOwner(), msg.sender);
        //assertEq(fundMe1.i_owner(), address(this));[passed]
        //assertEq(fundMe1.i_owner(), fundMe.i_owner());[passed]
    }

    function getVersionTesting() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function fundFailswithoutMinDollar() public {
        vm.expectRevert(); //this will fail if next line passess
        fundMe.fund(); //sending less than 5 dollars which is minimum
    }

    function testFundUpdatesFundedData() public {
        vm.prank(USER); //It says next txn is send by the USER

        fundMe.fund{value: SEND_AMOUNT}();
        /*
       console.log("address", fundMe.i_owner());
        console.log(
            "amount",
            fundMe.getAddressToAmountFunded(fundMe.i_owner())
        );
        console.log("amount", fundMe.getAddressToAmountFunded(address(this)));
        console.log(address(this));
        console.log(msg.sender);
        */

        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_AMOUNT);
    }

    //These cheatcodes only work in the test environment and only in foundry

    //pranking cheatcode is to be used to know who is hwho
    //It sets the msg.sender to the specified address for the next call which includes static calls as well but not calls to cheat code address

    //another cheatcode named makeAddr
    //It creates a new address with a given name

    //another cheatcode named deal
    //It sets the balance of an address who to newBalance

    function testAddsFunderToFunders() public funded {
        //vm.prank(USER);
        //fundMe.fund{value: SEND_AMOUNT}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); //this will fail if next line passess
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 12;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //We can do vm.prank(USER)
            //then vm.deal(USER, SEND_AMOUNT)
            //and then fundMe.fund{value: SEND_AMOUNT}();
            //but we are not doing it

            //instead we are using a new cheat code named hoax
            //SYNTAX: hoax(<address>, <amount>)
            //hoax is a cheat code that sends the specified amount of ether to the specified address
            //It is used to send ether to the contract from the specified address

            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{value: SEND_AMOUNT}();
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + startingFundMeBalance
        );
    }
    //another cheat code bruh for setting the gas price
    //It is txGasPrice , which sets the gas price for the next transaction
}
