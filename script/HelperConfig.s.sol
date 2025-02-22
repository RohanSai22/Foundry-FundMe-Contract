// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";

//import {FundMe} from "src/FundMe.sol";

import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on local anvil m we need to deploy the mocks
    //Otherwise , we can just use the real addresses from the live network

    //using constants like this is better approach and saving them is the best way for development
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; //ETH USD
        //
    }

    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetworkConfig;
    }

    function getMainnetNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory ethMainnetNetworkConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethMainnetNetworkConfig;
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //why? for getting default value of the price feed

        //Mocks for testing

        //1. Deploy the Mocks
        //2. Return the Mock addresses

        //for vm we need to have is Script for a contract

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilNetworkConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilNetworkConfig;
    }
}
