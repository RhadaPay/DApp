// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IPaymentStream{
    function setUserScores(address[] memory users, uint256[] memory scores) external;
    function updatePayments() external;
}

