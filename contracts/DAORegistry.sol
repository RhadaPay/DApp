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
        ContributorRegistry contributorRegistry; // Probably don't need b/c used in roundManager, RM has sufficient checks. Still need to deploy though
        RoundManager roundManager;
        PaymentStream paymentStream;
        // EventStream eventStream; // Does this exist?
        uint256 salaryPerRound;
    }

    /* ============ State Variables ============ */
    // List of DAOs
    DAO[] public daoList;
    // Mapping of DAO to DAO object
    mapping(address => uint256) public addressToDAO;
    // Mapping of DAO object to parent address
    mapping(uint256 => address) public daoToAddress; // Need? Might remove later if we can't find a good front/backend use case for
    // Mapping of address to bool. True if already have salary. False otherwise. -> adjust payment if already have
    // Mapping of round number to address to bool. True if already paid for round. False otherwise.

    event DaoRegistered(address parent);

    constructor () {
    }

    /**
     * Creates a new payment stream for the users from a specific round
     * 
     *
     * @param user       Address of the user who will be given a payment token
     *
     */
    function _createPaymentStream(address user, uint256 salary) private {

    }

    function register(uint8 _requiredConfirmations, uint256 _timePerRound, bool _timed, uint256 _salaryPerRound) public {
        daoList.push(DAO({
            contributorRegistry: (new ContributorRegistry(_requiredConfirmations)),
            roundManager: (new RoundManager(msg.sender, _timePerRound, _timed)), // Shouldn't be msg.sender. Need workaround
            paymentStream: (new PaymentStream()),
            salaryPerRound: _salaryPerRound
        }));
        emit DaoRegistered(msg.sender);
    }

    // Yes I know this is a disaster lol
    function calculateSalaries(uint256 daoID, uint256 roundID) public {
        // Logic should probably be moved elsewhere
        uint256 totalVotes = daoList[daoID].roundManager.getRoundVotes(roundID);
        address[] memory tmpUsers = daoList[daoID].roundManager.getRoundUsers(roundID);

        for(uint256 i = 0; i < tmpUsers.length; i++) {
            address tmpUser = tmpUsers[i];
            uint256 tmpUserVotes = daoList[daoID].roundManager.numVotes(roundID, tmpUser);
            uint256 salaryPercentage = tmpUserVotes / totalVotes * 100;
            // userPaidForRound[roundID][tmpUser] = true;
            // if(userHasStreamingToken[roundID][tmpUser]) {
            _createPaymentStream(tmpUser, salaryPercentage);
           // } else {
            // _adjustSalary(tmpUser, salaryPercentage)
           // }

        }

        
    }
}