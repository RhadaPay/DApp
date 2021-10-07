// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 import "./ContributorRegistry.sol";
/**
    Simple implementation of a voting contract done on-chain.
    This contract allows confirmed members to place votes for a particular member.
    This contract exports the votes but does not define a strategy.
    Votes for registered users are placed in Rounds, and the round manager contract coordinates rounds
    for a particular DAO.
    Rounds are not currently time bound, they are flexible and minimal.

    TODO:
        * Implement timer between rounds. Probably better on the frontend, but users may also want to block abuse
        * Implement a timeout between rounds so that the parent contract has enough time to process everything (prevents abuse)
 */
contract RoundManager {

    /* ============ Datatypes ============ */
    enum Status {
        Open,
        Completed,
        Cancelled
    }

    struct Round {
        Status status;
        uint256 startTime;
    }

    /* ============ State Variables ============ */
    // Stores rounds
    Round[] public rounds;
    // The registry of a specific DAO
    ContributorRegistry public registry;
    // List of addresses with admin privileges for a given DAO
    address[] public admins;
    // List of the addresses in the current round
    mapping(uint256 => address[]) public usersInRound;
    // Number of votes for a user in a given round
    mapping(uint256 => mapping(address => uint256)) public numVotes;
    // Mapping of round to those who have voted in that round
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Or just map uint256 to address and iterate through?
    // TEMPORARY MAPPING
    mapping(address => uint256) weightedVoting; // Use weighted voting identifier as way to communicate w registry about who can/can't vote
    // Timeout
    uint256 timePerRound;
    // If the DAOs choose to consider time
    bool timed;

    /* ============ Events ============ */

    event RoundOpened(uint256 roundID);
    event RoundOpenFailed();
    event RoundClosed(uint256 roundID, address closedBy);
    event VoteCast(uint256 roundID, address voter);

    /* Modifiers */

    modifier canVote(uint256 roundID) {
        require(!hasVoted[roundID][msg.sender] && weightedVoting[msg.sender] > 0);
        _;
    }

    modifier roundState(uint256 roundID, Status _status) {
        require(rounds[roundID].status == _status, "Round is not open");
        _;
    }
    
    modifier isAdmin() {
        bool ret = false;
        for(uint i = 0; !ret && i < admins.length; i++) {
            if(admins[i] == msg.sender) {
                ret = true;
            }
        }
        require(ret);
        _;
    }

    /* ============ Constructor ============ */

    constructor(address registryAddress, uint256 _timePerRound, bool _timed) {
        registry = ContributorRegistry(registryAddress);
        admins.push(msg.sender);
        timePerRound = _timePerRound;
        timed = _timed;
    }

    /* ============ Mutating Functions ============ */

    /**
     * Opens a new round.
     * Confirms that there exist valid users passed to the function before opening a new round.
     * A new round opens with a given salary to be split  amongst the contributors following the voting period.
     * 
     *
     * @param newUsers          Addresses of the proposed users to be eligible for votes
     *
     */
    function openRound(
        address[] memory newUsers
    ) public isAdmin {
        // Check to see if only round open
        require(rounds.length == 0 || rounds[rounds.length - 1].status != Status.Open);
        // Checks to see if there are valid users in the passed array
        for(uint256 i = 0; i < newUsers.length; i++) {
            address tmpUser = newUsers[i];
            if(registry.isValidVoter(tmpUser)) {
                usersInRound[rounds.length - 1].push(newUsers[i]);
            }
        }
        // If there are valid users, then create a new round. Else, do not open a new round
        if(usersInRound[rounds.length - 1].length > 0) {
            rounds.push(Round({
                status: Status.Open,
                startTime: block.timestamp
            }));
            uint256 roundID = rounds.length - 1;
            emit RoundOpened(roundID);
        } else {
            emit RoundOpenFailed();
        }
    }

    /**
     * Votes for users in a given round.
     * Confirms that the function caller is eligible to vote for a round.
     * The function caller casts his vote for the inputted addresses.
     * 
     *
     * @param roundID          The ID of the round
     * @param _for             The salary of the current round
     *
     */
    function castVote(
        uint256 roundID,
        address[] memory _for
    ) public canVote(roundID) roundState(roundID, Status.Open) {
        hasVoted[roundID][msg.sender] = true;
        for(uint256 i = 0; i < _for.length; i++) {
            numVotes[roundID][msg.sender] += weightedVoting[msg.sender]; // Add safe math later
        }
        emit VoteCast(roundID, msg.sender);
    }

    /**
     * Closes a given round.
     * Confirms that the given round is open.
     * The function caller casts his vote for the inputted addresses.
     * 
     *
     * @param roundID           The ID of the round
     * @param _newStatus        The new status, either closed or canceled, for the given round
     *
     */
    function closeRound(
        uint256 roundID,
        Status _newStatus
    ) public isAdmin {
        // Check for round status
        require(rounds[roundID].status == Status.Open, "The voting block is not closed");
        // Inputted round can only be either canceled or declared closed
        require(_newStatus != Status.Open, "Can only close or cancel a round");
        // Changes the round status
        rounds[roundID].status = _newStatus;
        emit RoundClosed(roundID, msg.sender);
    }

    /* ============ Getter Functions ============ */
}