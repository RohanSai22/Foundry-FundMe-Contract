// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";

import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //Before startBroadcast --> It is not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        address ethUdsPriceFeed = helperConfig.activeNetworkConfig();

        //After startBroadcast --> It is a real transaction

        vm.startBroadcast();
        //FundMe fundMe = new FundMe();

        FundMe fundMe = new FundMe(ethUdsPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}
