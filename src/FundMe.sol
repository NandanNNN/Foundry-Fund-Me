// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
import {PriceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();
error check();

contract FundMe {
    using PriceConvertor for uint;
    address[] private s_funders; //storage vaiables should start with s_
    mapping(address funder => uint amount) private s_addressToAmountFunded;
    address public immutable i_owner;
    uint256 public constant MIN_USD = 5e18; //constant because we declare and define variable here only
    AggregatorV3Interface private s_priceFeed;

    constructor(address pricefeed) {
        i_owner = msg.sender;
        //immutable beacause we are defining variable above and using it here
        s_priceFeed = AggregatorV3Interface(pricefeed);
    }

    //immutable and constant keyword saves lot's of gas because it is save in bytecode of ontract
    //insted of storage slot

    function fund() public payable {
        //msg.value will be first parameter in getConversion
        //if we pass something else in getConversion parameter
        //then it will be 2nd,3rd parameter and so on
        //5e18 is 5$
        require(msg.value.getConversion(s_priceFeed) >= MIN_USD, "low eth"); // 1e18 = 1 eth = 1 * 10**18 (18 zeroes)
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (uint index = 0; index < s_funders.length; index++) {
            s_addressToAmountFunded[s_funders[index]] = 0;
        }
        s_funders = new address[](0);
        //below are three ways to transfer money from contract to wallet
        //transfer -> in case of error it will automaticaally erevert transaction
        /**
        payable(msg.sender).transfer(address(this).balance);
        //send
        bool sendSucess = payable(msg.sender).send(address(this).balance);
        require(sendSucess, "send Transactiopn failed");
        **/
        //call --> recommended way as of now
        (bool callSuccess /*bytes memory dataReturned */, ) = payable(
            msg.sender
        ).call{value: address(this).balance}("");
        require(callSuccess, "call transaction failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "only owner can fetch");
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }
        //reverting with if is more gas efficient because here we are not saving error string "only owner can fetch"
        //we can use revert(); at any place to revert a piece of code
        // _; defines that executes whatever in the funtion now
        //if we declare _; before require then it will execute function first and then other
        //require statement;
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //view functions below
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint index) external view returns (address) {
        return s_funders[index];
    }
}
