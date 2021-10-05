//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IVoterRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract ContributorRegistry is Ownable, IVoterRegistry{
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ============ Datatypes ============ */
    enum Status {NONE, REGISTERED, CONFIRMED}
    struct Contributor {
        Status status;
        uint8 numConfirmationVotes;
        mapping (address => bool) confirmationVotes;
        string discordHandle;
        string githubUsername;
    }

    /* ============ State Variables ============ */
    // Number of confirmation votes needed for a contributor to be confirmed
    uint8 public requiredConfirmations;
    // Mapping to save contributor data for each address
    mapping (address => Contributor) public contributors;
    // Mappings used to ensure every discord handle / github username is registered only once
    mapping (string => bool) registeredDiscordHandles;
    mapping (string => bool) registeredGithubUsernames;
    // List of registered (including non-confirmed) contributor addresses
    EnumerableSet.AddressSet private registeredAddresses;

    /* ============ Events ============ */
    event Registered(address contributor, string discordHandle, string githubUsername);
    event UnRegistered(address contributor);
    event ConfirmationVote(address contributor, address voter, uint8 numVotes);
    event ContributorConfirmed(address contributor);

    /* ============ Constructor ============ */

    constructor(uint8 _requiredConfirmations) public {
        requiredConfirmations = _requiredConfirmations;
    }

    /* ============ Mutating Functions ============ */

    /**
     * Register the senders address as a contributor pending confirmation.
     *
     * @param _discordHandle            Discord Handle to map to the senders address
     * @param _githubUsername            Github username to map to the senders address
     *
     */
    function register(string memory _discordHandle, string memory _githubUsername) public {
        require(contributors[msg.sender].status == Status.NONE, "Account has registered already");
        require(!registeredDiscordHandles[_discordHandle], "Discord handle is already registered");
        require(!registeredGithubUsernames[_githubUsername], "Github username is already registered");

        registeredAddresses.add(msg.sender);
        registeredDiscordHandles[_discordHandle] = true;
        contributors[msg.sender].discordHandle = _discordHandle;

        registeredGithubUsernames[_githubUsername] = true;
        contributors[msg.sender].githubUsername = _githubUsername;

        contributors[msg.sender].status = Status.REGISTERED;
        emit Registered(msg.sender, _discordHandle, _githubUsername);
    }

    /**
     * Confirm the registration of given address.
     * If the caller is the contract owner he can confirm a registration unilaterally otherwise the call is
     * treated as a vote for confirmation.
     *
     * @param _contributorAddress       Address of the account whose registration is to be confirmed
     *
     */
    function confirm(address _contributorAddress) public {
        require(contributors[msg.sender].status == Status.CONFIRMED || msg.sender == owner(), "Voter has to be a confirmed contributor or contract owner");

        Contributor storage contributor = contributors[_contributorAddress];
        require(contributor.status == Status.REGISTERED, "Contributor is not in confirmation process");
        require(!contributor.confirmationVotes[msg.sender], "Voter already voted for this contributor");

        contributor.confirmationVotes[msg.sender] = true;
        contributor.numConfirmationVotes++;
        emit ConfirmationVote(_contributorAddress, msg.sender, contributor.numConfirmationVotes);

        if(contributor.numConfirmationVotes >= requiredConfirmations || msg.sender == owner()){
            contributor.status = Status.CONFIRMED;
            emit ContributorConfirmed(_contributorAddress);
        }
    }


     /**
     * Delete a contributor from the registry.
     * Can only be called by the contract owner address.
     *
     * @param _contributorAddress       Address of the account whose registration is to be deleted
     *
     */
    function unregister(address _contributorAddress) public {
        require(msg.sender == owner(), "Only owner can delete contributors");

        Contributor storage contributor = contributors[_contributorAddress];

        registeredDiscordHandles[contributor.discordHandle] = false;
        registeredGithubUsernames[contributor.githubUsername] = false;
        // TODO: This will not reset the confirmationVotes nested mapping
        delete contributors[_contributorAddress];
        registeredAddresses.remove(_contributorAddress);
        emit UnRegistered(_contributorAddress);
    }


    /* ============ Getter Functions ============ */
    function numRegisteredContributors() public view returns(uint256){
        return registeredAddresses.length();
    }

    function registeredContributorAddresses() public view returns(address[] memory){
        return registeredAddresses.values();
    }

    function isValidVoter(address user) external override returns (bool){
        return contributors[user].status == Status.CONFIRMED;
    }

}
