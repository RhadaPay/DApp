// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventStream {
    struct EventToken {
        address owner;
        uint256 data;
    }

    mapping(address => uint256) public userToEventStream; 

    EventToken[] tokenList;

    constructor() {

    }

    function createEventStream(address _owner, uint256 _data) public {
        tokenList.push(EventToken({
            owner: _owner,
            data: _data
        }));
    }
}