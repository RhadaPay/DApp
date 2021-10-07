// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContributorRegistry.sol";
import "./RoundVoting.sol";

/* This is the Rhada parent contract. Here is the following flow:
 * DAOs will register to join the Rhada protocol and will list the following:
 *      - Address of the contract/user that will interact with the Rhada Protocol
 *      - Funds/Fund type: funds can come later but addresses of the DAO's ERC20 token
 * Upon registering,
 *      - Will deploy a new ContributorRegistry contract specific to that DAO
 *              - Manages devs, voting process for who is a contributor
 *      - Will deploy a new RoundVoting contract specific to that DAO
 *              - Manages rounds and voting on specific users in a round. Used to define how salary gets split
 *              - Possible (and probably necessary) feature: rewards DAO members for participating
 *      - Will deploy a PaymentStream contract specific to that DAO
 *              -
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 

*/


contract DAORegistry is Ownable {
    /* ============ Datatypes ============ */
    enum Status {NONE, REGISTERED, CONFIRMED}
    struct DAO {
        Status status;

    }

    /* ============ State Variables ============ */
    // List of DAOs
    DAO[] public list;
    // Mapping of DAO to Voting contract
    mapping(address => address) public daoToVoting;
    // Mapping of DAO to Contributor Registry
    mapping(address =>)

    /**
        Constructor Function
        @param streamAddress The contract address used to manage payment streams.
        @param roundAddress The contract address where round voting details can be found.
        @param registryAddress The contract address where registered contributors and confirmed
                                members can be found.
     */
    constructor (address streamAddress, address roundAddress, address registryAddress) {
        // stream = PaymentStream(streamAddress);
        round = RoundVoting(roundAddress);
        registry = ContributorRegistry(registryAddress);
    }
/*

    
*/
}