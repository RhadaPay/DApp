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
        uint roundSalary;
    }

    /* ============ State Variables ============ */
    // Stores rounds
    Round[] public rounds;
    // The registry of a specific DAO
    ContributorRegistry public registry;
    // List of addresses with admin privileges for a given DAO
    address[] public admins;
    // List of the addresses in the current round
    mapping(uint => address[]) usersInRound;
    // Number of votes for a user in a given round
    mapping(uint => mapping(address => uint)) numVotes;
    // Mapping of round to those who have voted in that round
    mapping(uint => mapping(address => bool)) public hasVoted; // Or just map uint to address and iterate through?
    // TEMPORARY MAPPING
    mapping(address => uint) weightedVoting; // Use weighted voting identifier as way to communicate w registry about who can/can't vote
    // Timeout
    uint256 timePerRound;

    /* Events */
    event VoteCast(address _for, address _by);
    event RoundOpen(uint roundID);
    event RoundCompleted(uint roundID);
    event RoundCancelled(uint roundID);
    event VotesCalculated(uint roundID);

    /* Modifiers */

    modifier canVote(uint256 roundID) {
        require(!hasVoted[roundID][msg.sender] && weightedVoting[msg.sender] > 0);
        _;
    }

    modifier roundIsOpen(uint256 roundID) {
        require(rounds[roundID].status == Status.Open, "Round is not open");
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
        Creates a new round of voting
    */
    function openRound(
        address[] memory newUsers, uint256 _roundSalary
    ) public {
        bool validUsersInRound = false;
        for(uint i = 0; i < newUsers.length; i++) {
            /*
            if(newUsers[i] in registry) {
                validUsersInRound = true;
                usersInRound[rounds.length - 1].push(newUsers[i]);
            }
            */
        }
        if(validUsersInRound) {
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
        @param roundID: numerical identifier found in the Round struct
        @param _for: the address of the person for whom you're voting
     */
    function castVote(
        uint256 roundID,
        address[] memory _for
    ) public roundIsOpen(roundID) {
        hasVoted[roundID][msg.sender] = true;
        for(uint i = 0; i < _for.length; i++) {
            numVotes[roundID][msg.sender] += weightedVoting[msg.sender];
        }
        
        // emit VoteCast();
    }

    /**
        Closes an existing round of voting
     */
    function closeRound(
        uint roundID, Status _newStatus
    ) public {
        require(rounds[roundID].status == Status.Open, "The voting block is not closed");
        require(_newStatus != Status.Open);
        rounds[roundID].status = _newStatus;
        // emit RoundClosed();
    }
}