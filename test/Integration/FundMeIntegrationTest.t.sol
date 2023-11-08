// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
import "../../src/FundMe.sol";
//import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeplyFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

//import {Test, console} from "forge-std/Test.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BAL = 10 ether;
    uint constant GAS_PRICE = 1;

    // Creating a test user for address matching
    // Only valid for test env and it is derived from forge-std library
    address USER = makeAddr("USER");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        console.log("setup called");
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BAL);
    }

    function testfundIntegration() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(USER);
        //vm.deal(USER, 1e18);
        fundFundMe.fundFundMe(address(fundMe));

        address funderAddress = fundMe.getFunders(0);
        console.log(funderAddress);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
