//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContributorRegistry.sol";
/**
    Simple implementation of a voting contract done on-chain.
    This contract allows confirmed members to place votes for a particular member.
    This contract exports the votes but does not define a strategy.
    Votes for registered users are placed in Rounds, and the round manager contract coordinates rounds
    for a particular DAO.
    Rounds are not currently time bound, they are flexible and minimal.

    TODO:
        * Decide on cooldown/warmup - could be implemented as a status
        * Determine a gas-efficient way to expose how many votes were received for each user.
        * implement admin functionality
 */
contract RoundManager is Ownable {

    /* Data */
    enum Status {
        Created, // decide if this is needed before Round Opens
        Open,
        Completed,
        Cancelled
    }

    struct Round {
        Status status;
        address[] membersWhoReceievedVotes; // Enumerable set/mapping from OZ?         
        mapping (address => address[]) votesForUser; // do we need this
        mapping (address => uint) numberOfVotesReceived; // and this?
        mapping(address => bool) memberHasVoted; 
        mapping (address => bool) admins; // how should this be implemented
    }

    Round[] rounds;
    ContributorRegistry registry;

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
        // Contributor contributor = registry.contributors(user);
        _;
    }

    modifier userHasNotVoted(uint roundId) {
        Round storage currentRound = rounds[roundId];
        require(!currentRound.memberHasVoted[msg.sender], "Member has already voted");
        _;
    }

    /**
        Certain actions should be restricted to trusted members of the DAO 
        @dev how to implement - we possibly need some additional functionality  
     */
    modifier isAdmin() {
        _;
    }

    /** 
        Calls the ContributorRegistry contract to validate the user
        has the right to vote, based on whether they are registered or not.
     */
    modifier isAllowedToVote() {
        _;
    }

    /**
        Ensures there are no currently open rounds
     */
    modifier noOpenRounds() {
        Round storage latestRound = rounds[rounds.length - 1];
        require(latestRound.status != Status.Open);
        _;
    }

    modifier roundIsOpen(uint roundId) {
        Round storage round = rounds[roundId];
        require(round.status == Status.Open, "Round is not open");
        _;
    }

    /**
        Constructor function
        @param registryAddress: this is the contract address where the list of registered
            and confirmed members of the dao can be found
     */     
    constructor(address registryAddress) {
        registry = ContributorRegistry(registryAddress);
    }
    
    /* Methods */

    /**
        @param roundId: numerical identifier found in the Round struct
        @param _for: the address of the person for whom you're voting
        @param numOfVotes: different voting strategies may allow > 1 person 1 vote
     */
    function castVote(
        uint roundId,
        address _for,
        uint numOfVotes
        ) public isConfirmedUser(_for) isAllowedToVote roundIsOpen(roundId) userHasNotVoted(roundId) {
        // emit VoteCast();
    }

    /**
        Extend castVote functionality for multiple votes
        @param _for: list of addresses to vote for
        @param votes: how many votes for the address at index i
     */
    function castVotes(
        address[] memory _for ,
        uint[] memory votes,
        uint roundId
        ) public isAllowedToVote roundIsOpen(roundId) userHasNotVoted(roundId) {

        for (uint i = 0; i < _for.length - 1; i++) {
            castVote(roundId, _for[i], votes[i]);
        }
    }

    /**
        Creates a new round of voting
     */
    function openRound() public noOpenRounds {
        // emit RoundOpened();
    }

    /**
        Closes an existing round of voting
     */
    function closeRound(uint roundId) public isAdmin roundIsOpen(roundId) {
        calculateVotes(roundId);
        // emit RoundClosed();
    }

    /**
        Cancels an open round of voting
     */
    function cancelRound(uint roundId) public isAdmin roundIsOpen(roundId) {
        // emit RoundCancelled();
    }

    /**
        This is a somewhat tricky function. We need a gas-efficient way to calculate
        the votes for each user, then we need to make that data available for a payment contract
        to be executed accordingly.
     */
    function calculateVotes(uint roundId) public isAdmin {
        // emit VotesCalculated();
    }
}