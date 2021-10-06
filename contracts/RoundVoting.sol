//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "./ContributorRegistry.sol";
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
    // ContributorRegistry public registry;
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

    /**
        Calls the ContributorRegistry contract to validate the user being voted
        for is eligible to receive votes
        @dev this probably needs a check implemented in the other contract
     */
    modifier isConfirmedUser(address user) {
        // require(registry.contributors(user) == ??)
        _;
    }

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
        //registry = ContributorRegistry(registryAddress);
        admins.push_back(msg.sender);
        timePerRound = _timePerRound;
    }

    /* Public Methods */

    /**
        Creates a new round of voting
    */
    function openRound(
        address[] memory newUsers, uint256 _roundSalary
    ) public {
        rounds.push_back(Round({
            status: Status.Open,
            roundSalary: _roundSalary
        }));
        usersInRound[rounds.size - 1] = newUsers;
        // emit RoundOpened();
    }

    /**
        @param roundID: numerical identifier found in the Round struct
        @param _for: the address of the person for whom you're voting
     */
    function castVote(
        uint256 roundID,
        address[] memory _for
    ) public isConfirmedUser(_for) roundIsOpen(roundID) {
        hasVoted[roundID][msg.sender] = true;
        for(int i = 0; i < _for.size; i++) {
            numVotes[roundID][msg.sender] += weightedVoting[msg.sender];
        }
        
        // emit VoteCast();
    }

    /**
        Closes an existing round of voting
     */
    function closeRound(
        uint roundID
    ) public {
        require(rounds[roundID].status == Status.Closed, "The voting blocl is not closed");
        // emit RoundClosed();
    }
}