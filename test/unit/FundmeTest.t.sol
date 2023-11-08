// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
import "../../src/FundMe.sol";
//import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeplyFundMe.s.sol";

//import {Test, console} from "forge-std/Test.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BAL = 10 ether;
    uint constant GAS_PRICE = 1;

    // Creating a test user for address matching
    // Only valid for test env and it is derived from forge-std library
    address USER = makeAddr("USER");

    uint256 number;

    function setUp() external {
        number = 2;
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BAL); //setting initial bal of user
    }

    function testDemo() public {
        console.log(number);
        assertEq(number, 2);
        assertEq(fundMe.MIN_USD(), 5e18);
        console.log(6e18);
    }

    function testOwnercheck() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersion() public {
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundMeFail() public {
        vm.expectRevert(); //Refer foundry cheat code for more vm function
        //vm.expectRevert() = next line should revert
        fundMe.fund(); // sending 0$
    }

    modifier funder() {
        vm.prank(USER); //next txn will be sent by user
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundMePass() public funder {
        // vm.prank(USER); //next txn will be sent by user
        // fundMe.fund{value: SEND_VALUE}();
        uint amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
        address funderAddress = fundMe.getFunders(0);
        console.log(funderAddress);
        assertEq(funderAddress, USER);
    }

    function testOnlyOwnerCanWithdrawFail() public funder {
        //vm.prank(USER);
        //fundMe.fund{value: SEND_VALUE}();

        // vm.prank(USER);
        vm.expectRevert(); //vm.user will ignore next vm line
        fundMe.withdraw();
    }

    function testOnlyOwnerCanWithdrawPass() public funder {
        //Arrange
        uint startingOwnerBalance = fundMe.i_owner().balance;
        uint startingfundMeBalance = address(fundMe).balance;
        console.log(startingfundMeBalance);
        console.log(startingOwnerBalance);

        //Act
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        //Assert
        uint endingOwnerBalance = fundMe.i_owner().balance;
        uint endingfundMeBalance = address(fundMe).balance;
        assertEq(endingfundMeBalance, 0);
        console.log(endingOwnerBalance);
        assertEq(
            startingfundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    //url with time = https://youtu.be/sas02qSFZ74?t=5361
    function testwithdrawMultiple() public funder {
        //vm.hoax = vm.prank + vm.deal
        //vm.hoax = create an address with some amount of eth
        //uint160 --> use it for addresses, numbers used in generating addresses should be uint160

        //Arrange
        uint160 startingIndex = 1; //make sure never start iterating address from address 0 because it will clear adrdress during sanity
        uint160 numberOfFunder = 10;

        for (uint160 i = startingIndex; i < numberOfFunder; i++) {
            hoax(address(i), STARTING_BAL);
            fundMe.fund{value: STARTING_BAL}();
        }
        uint startingOwnerBalance = fundMe.i_owner().balance;
        uint startingfundMeBalance = address(fundMe).balance;
        console.log(startingOwnerBalance);
        console.log(startingfundMeBalance);

        //Act
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        //assert
        uint endingOwnerBalance = fundMe.i_owner().balance;
        uint endingfundMeBalance = address(fundMe).balance;
        assertEq(endingfundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingfundMeBalance
        );
    }
}
