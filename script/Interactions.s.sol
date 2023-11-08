//Script for Fund and withdraw
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

//Why we are using DevopsTools = https://youtu.be/sas02qSFZ74?t=7342
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundME with %s", SEND_VALUE);
        console.log("check if it's updated");
    }

    function run() external {
        address mostRecentDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        console.log("run() function called ");
        fundFundMe(mostRecentDeployedContract);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentDeployedContract);
    }
}
