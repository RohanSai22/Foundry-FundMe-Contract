// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe} from "script/Interactions.s.sol";
import {WithdrawFundMe} from "script/Interactions.s.sol";

contract InteractionsTest is Test {
    uint256 num = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_AMOUNT = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 2;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(USER);
        //vm.deal(USER,1e18);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        //address funder = fundMe.getFunder(0);
        //assertEq(funder, USER);

        assertEq(address(fundMe).balance, 0);
    }
}
