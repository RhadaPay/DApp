// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentStream {
    struct PaymentToken {
        address owner;
        uint256 totalAmount;
    }

    mapping(address => uint256) public userToPaymentStream; 

    PaymentToken[] tokenList;

    constructor() {

    }

    function createPaymentStream(address _owner, uint256 _totalAmount) public {
        tokenList.push(PaymentToken({
            owner: _owner,
            totalAmount: _totalAmount
        }));
    }
}