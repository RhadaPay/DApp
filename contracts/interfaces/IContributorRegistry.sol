// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IContributorRegistry{
    function isValidVoter(address user) external returns (bool);
}

