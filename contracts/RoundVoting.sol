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
        * Implement ability to modify the timeout
        * Implement weighted voting
        * Implement group voting? Can just give people the ability to vote for multiple rounds at once to save on space
        * Different structs for different types of voting (more expensive deployment -> save lots for users)
 */
contract RoundManager {

    /* Data */
    enum Status {
        Open,
        Completed,
        Cancelled
    }

    struct Round {
        Status status;
        uint256 roundSalary;
    }

    /* ============ State Variables ============ */
    // Stores rounds
    Round[] public rounds;
    // The registry of a specific DAO
    ContributorRegistry public registry;
    // List of addresses with admin privileges for a given DAO
    address[] public admins;
    // List of the addresses in the current round
    mapping(uint256 => address[]) usersInRound;
    // Number of votes for a user in a given round
    mapping(uint256 => mapping(address => uint256)) numVotes;
    // Mapping of round to those who have voted in that round
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Or just map uint256 to address and iterate through?
    // TEMPORARY MAPPING
    mapping(address => uint256) weightedVoting; // Use weighted voting identifier as way to communicate w registry about who can/can't vote
    // Timeout
    uint256 timePerRound;

    /* Events */
    event VoteCast(address _for, address _by);
    event RoundOpen(uint256 roundID);
    event RoundCompleted(uint256 roundID);
    event RoundCancelled(uint256 roundID);
    event VotesCalculated(uint256 roundID);

    /* Modifiers */

    modifier canVote(uint256 roundID) {
        require(!hasVoted[roundID][msg.sender] && weightedVoting[msg.sender] > 0);
        _;
    }

    modifier roundState(uint256 roundID, Status _status) {
        require(rounds[roundID].status == _status, "Round is not open");
        _;
    }

    /**
        Constructor function
        @param registryAddress: this is the contract address where the list of registered
            and confirmed members of the dao can be found
    */     
    constructor(address registryAddress, uint256 _timePerRound) {
        registry = ContributorRegistry(registryAddress);
        admins.push(msg.sender);
        timePerRound = _timePerRound;
    }

    /* Public Methods */

    /**
     * Opens a new round.
     * Confirms that there exist valid users passed to the function before opening a new round.
     * A new round opens with a given salary to be split later amongst the contributors.
     * 
     *
     * @param newUsers          Addresses of the proposed users to be eligible for votes 
     * @param _roundSalary      The salary of the current round
     *
     */
    function openRound(
        address[] memory newUsers, uint256 _roundSalary
    ) public {
        // Checks to see if there are valid users in the passed array
        for(uint256 i = 0; i < newUsers.length; i++) {
            /*
            if(newUsers[i] in registry) {
                validUsersInRound = true;
                usersInRound[rounds.length - 1].push(newUsers[i]);
            }
            */
        }
        // If there are valid users, then create a new round. Else, do not open a new round
        if(usersInRound[rounds.length - 1].length > 0) {
            rounds.push(Round({
                status: Status.Open,
                roundSalary: _roundSalary
            }));
            // emit RoundOpened();
        } else {
            // emit round failed to open
        }
    }

    /**
     * Opens a new round.
     * Confirms that there exist valid users passed to the function before opening a new round.
     * A new round opens with a given salary to be split later amongst the contributors.
     * 
     *
     * @param roundID          Addresses of the proposed users to be eligible for votes 
     * @param _for             The salary of the current round
     *
     */
    function castVote(
        uint256 roundID,
        address[] memory _for
    ) public roundState(roundID, Status.Open) {
        hasVoted[roundID][msg.sender] = true;
        for(uint256 i = 0; i < _for.length; i++) {
            numVotes[roundID][msg.sender] += weightedVoting[msg.sender];
        }
        
        // emit VoteCast();
    }

    /**
        Closes an existing round of voting
     */
    function closeRound(
        uint256 roundID, Status _newStatus
    ) public {
        require(rounds[roundID].status == Status.Open, "The voting block is not closed");
        require(_newStatus != Status.Open);
        rounds[roundID].status = _newStatus;
        // emit RoundClosed();
    }
}