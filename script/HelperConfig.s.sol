// SPDX-License-Identifier: MIT

// 1. Deploy mock contract on anvil chain so that we don't have to call alchey url again and agin and hence save cost
// remember testing with Alchemy is also imp but not always
// 2. keep track of contracts across different chains.

pragma solidity 0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on local anvil we will deploy mocks
    //Otherwise, grab the existing address from live network

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //return on chain contract
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    //This is needed because we don't need to call alchemy and wait for response
    //this is much faster way to test since here it will internally run on anvil
    //Calling alchemy again and again will cause rise in bill
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        //1. deploy mocks
        //2. Return Mock address

        //Below if block is checking if we have already deployed mock contract
        //https://youtu.be/sas02qSFZ74?t=3663
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
