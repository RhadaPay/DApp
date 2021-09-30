//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "@openzeppelin/contracts/access/Ownable.sol";
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
 */
contract RoundManager is Ownable {

    /* Data */
    enum Status {
        Open,
        Completed,
        Cancelled
    }

    struct Round {
        Status status;
        address newUser;
        uint128 numVotes;
        uint128 endTime; // What uint does time use again
    }

    /* ============ State Variables ============ */
    // Stores rounds
    Round[] public rounds;
    // The registry of a specific DAO
    ContributorRegistry public registry;
    // List of addresses with admin privileges for a given DAO
    address[] public admins;
    // Mapping of round to those who have voted in that round
    mapping(uint => mapping(address => bool)) public hasVoted; // Or just map uint to address and iterate through?
    // TEMPORARY MAPPING
    mapping(address => uint) weightedVoting;
    // Timeout
    uint256 timeout;

    /* Events */
    event VoteCast(address _for, address _by);
    event RoundOpen(uint roundId);
    event RoundCompleted(uint roundId);
    event RoundCancelled(uint roundId);
    event VotesCalculated(uint roundId);

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

    modifier userHasNotVoted(uint roundId) {
        require(!hasVoted[roundID][msg.sender], "Member has already voted");
        _;
    }

    /** 
        Calls the ContributorRegistry contract to validate the user
        has the right to vote, based on whether they are registered or not.
    */
    modifier canVote() {
        require(weightedVoting[msg.sender] > 0);
        _;
    }

    modifier roundIsOpen(uint roundId) {
        _checkTime(roundId);
        require(rounds[roundId].status == Status.Open, "Round is not open");
        _;
    }

    /**
        Constructor function
        @param registryAddress: this is the contract address where the list of registered
            and confirmed members of the dao can be found
    */     
    constructor(address registryAddress, uint256 _timeout) {
        registry = ContributorRegistry(registryAddress);
        admins.push_back(msg.sender);
        timeout = _timeout;
    }

    /* Private Methods */
    function _checkTime(uint256 roundId) private {
        if(block.timestamp > endtime) {
            rounds[roundId].status = Status.Closed;
        }
    }

    /* Public Methods */

    /**
        Creates a new round of voting
    */
    function openRound(
        address _newUser
    ) public {
        rounds.push_back(Round({
            status: State.Open,
            newUser: _newUser,
            numVotes: 0,
            endTime: block.timestamp + timeout
        }));
        // emit RoundOpened();
    }

    /**
        @param roundId: numerical identifier found in the Round struct
        @param _for: the address of the person for whom you're voting
     */
    function castVote(
        uint roundId,
        address _for
    ) public isConfirmedUser(_for) isAllowedToVote roundIsOpen(roundId) userHasNotVoted(roundId) {
        hasVoted[roundId][msg.sender] = true;
        rounds[roundID].numVotes += 1; // add safe math
        // emit VoteCast();
    }

    /**
        Closes an existing round of voting
     */
    function closeRound(
        uint roundId
    ) public {
        _updateTime(roundId);
        require(rounds[roundId].status == Status.Closed, "The voting blocl is not closed");
        calculateVotes(roundId);
        // emit RoundClosed();
    }
}