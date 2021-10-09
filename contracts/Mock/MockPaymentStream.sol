// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentStream {
    struct PaymentToken {
        address tokenOwner;
        uint256 totalAmount;
        uint256 salaryPeriod;
    }

    mapping(address => uint256) public userToPaymentStream; 

    PaymentToken[] tokenList;

    constructor() {

    }

    function createPaymentStream(address _tokenOwner, uint256 _totalAmount, uint256 _salaryPeriod) public {
        tokenList.push(PaymentToken({
            tokenOwner: _tokenOwner,
            totalAmount: _totalAmount,
            salaryPeriod: _salaryPeriod
        }));
    }

    function adjustPaymentStream(address _tokenOwner, uint256 newAmount) public {
        uint256 id = userToPaymentStream[_tokenOwner];
        tokenList[id].totalAmount = newAmount;
    }
}