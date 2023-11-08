// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    // get eth price from chainlink
    function getPrice(
        AggregatorV3Interface price
    ) internal view returns (uint) {
        (
            ,
            /* uint80 roundID */ int answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = price.latestRoundData();
        //2000.00000000
        return uint(answer * 1e10); //1e10 = add additional 10 decimal
    }

    //convert msg.value to usd
    function getConversion(
        uint ethAmount,
        AggregatorV3Interface price
    ) internal view returns (uint) {
        uint ethPrice = getPrice(price);
        uint ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        //we divide by 1e18 because on multiplying ethPrice and ethAmount we get 18 zeroes
        //so we want only 18 zeroes hence divinding by 18 zeores to
        // 1st video 4:52:57
        return ethAmountInUsd;
    }
}
