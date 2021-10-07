// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContributorRegistry.sol";
import "./RoundManager.sol";
import "./Mock/MockEventStream.sol";
import "./Mock/MockPaymentStream.sol";

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
 *              - Controls the setting up of payments
 *      - Will deploy an EventStream contract specific to that DAO
 *              - Controls monitoring of no idea
 * DAO parent address will map to address of each one
 * Contracts compiles data from all of them
 *      - ContributorRegistry
 *          - Don't know what to use from this
 *      - RoundVoting
 *          - Needs votes + users (will use to split salary among them all)
 *      - PaymentStream
 *          - Will start payment stream from this contract
 * Also managed here:
 *      - Weighted voting (DAO -> weighted voting. Can act as a user registry per DAO)
 *      - Lists all contributors, payments streams, and other important data
*/


contract DAORegistry is Ownable {
    /* ============ Datatypes ============ */
    struct DAO {
        ContributorRegistry contributorRegistry; // Probably don't need
        RoundManager roundManager;
        PaymentStream paymentStream;
        // EventStream eventStream; // Does this exist?
    }

    /* ============ State Variables ============ */
    // List of DAOs
    DAO[] public daoList;
    // Mapping of DAO to DAO object
    mapping(address => uint256) public addressToDAO;
    // Mapping of DAO object to parent address
    mapping(uint256 => address) public daoToAddress; // Need? Might remove later if we can't find a good front/backend use case for

    event DaoRegistered(address parent);

    constructor () {
    }

    /**
     * Creates a new payment stream for the users from a specific round
     * 
     *
     * @param roundID       The ID of the most recently closed round
     *
     */
    function _createPaymentStream(address user, uint256 salary) private {

    }

    function register(uint8 _requiredConfirmations, uint256 _timePerRound, bool _timed) public {
        daoList.push(DAO({
            contributorRegistry: (new ContributorRegistry(_requiredConfirmations)),
            roundManager: (new RoundManager(msg.sender, _timePerRound, _timed)), // Shouldn't be msg.sender. Need workaround
            paymentStream: (new PaymentStream())
        }));
        emit DaoRegistered(msg.sender);
    }
    
    function calculateSalaries() public {
        // Flow: calc total votes, input percentage into a for loop w createPaymentStream method
    }
}