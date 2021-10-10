// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContributorRegistry.sol";
import "./RoundManager.sol";
import "./PaymentStream.sol";

/* This is the Rhada parent contract. Here is the following flow:
 * DAOs will register to join the Rhada protocol and will list the following:
 *      - Address of the contract/user that will interact with the Rhada Protocol
 *      - Funds/Fund type: funds can come later but addresses of the DAO's ERC20 token
 * Upon registering,
 *      - Will deploy a new ContributorRegistry contract specific to that DAO
 *              - Manages devs, voting process for who is a contributor
 *              - Need to launch here, don't need in struct. RoundManager uses its data, not this contract
 *      - Will deploy a new RoundVoting contract specific to that DAO
 *              - Manages rounds and voting on specific users in a round. Used to define how salary gets split
 *              - Possible (and probably necessary) feature: rewards DAO members for participating
 *      - Will deploy a PaymentStream contract specific to that DAO
 *              - Controls the setting up of payments
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
        string name;
        ContributorRegistry contributorRegistry; // Probably don't need b/c used in roundManager, RM has sufficient checks. Still need to deploy though
        RoundManager roundManager;
        PaymentStream paymentStream;
        uint256 salaryPerRound;
        uint256 salaryPeriod;
    }

    /* ============ State Variables ============ */
    // List of DAOs
    DAO[] public daoList;
    // Mapping of DAO to DAO object
    mapping(address => uint256) public addressToDAO;
    // Mapping of DAO object to parent address
    mapping(uint256 => address) public daoToAddress; // Need? Might remove later if we can't find a good front/backend use case for
    // Mapping of address to bool. True if already have salary. False otherwise. -> adjust payment if already have
    mapping(address => bool) public hasSalary;
    // Mapping of round number to address to bool. True if already paid for round. False otherwise.
    mapping(uint256 => mapping(address => bool)) public userPaidForRound;
    // Payment stream length

    event DaoRegistered(string name, uint256 daoId, address parent);

    IConstantFlowAgreementV1 private _cfa;
    ISuperfluid private _host;

    constructor (IConstantFlowAgreementV1 cfa, ISuperfluid superfluid) {
        _cfa = cfa;
        _host = superfluid;
    }


    function register(string memory name, uint8 _requiredConfirmations, uint256 _timePerRound, bool _timed, uint256 _salaryPerRound, uint256 _salaryPeriod) public {
        daoList.push(DAO({
            name: name,
            contributorRegistry: (new ContributorRegistry(_requiredConfirmations)),
            roundManager: (new RoundManager(msg.sender, _timePerRound, _timed)), // Shouldn't be msg.sender. Need workaround
            paymentStream: (new PaymentStream(_cfa, _host, msg.sender)),
            salaryPerRound: _salaryPerRound,
            salaryPeriod: _salaryPeriod

        }));
        emit DaoRegistered(name, daoList.length - 1, msg.sender);
    }


    function distributeSalaries(uint256 daoID) public {
        uint256 roundID = daoList[daoID].roundManager.getRoundNumber();
        // Logic should probably be moved elsewhere
        uint256 totalVotes = daoList[daoID].roundManager.getRoundVotes(roundID);
        address[] memory tmpUsers = daoList[daoID].roundManager.getRoundUsers(roundID);
        uint256[] memory votesPerUser;
        for(uint256 i = 0; i < tmpUsers.length; i++) {
            address tmpUser = tmpUsers[i];
            uint256 tmpUserVotes = daoList[daoID].roundManager.numVotes(roundID, tmpUser);
            uint256 salaryPercentage = tmpUserVotes / totalVotes * 100;
            votesPerUser[i] = salaryPercentage;
        }
        daoList[daoID].paymentStream.setUserScores(tmpUsers, votesPerUser);
        daoList[daoID].paymentStream.updatePayments();
    }
}