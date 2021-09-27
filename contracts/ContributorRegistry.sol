//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContributorRegistry is Ownable{

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
    uint8 public requiredConfirmations;
    mapping (address => Contributor) public contributors;
    mapping (string => bool) registeredDiscordHandles;
    mapping (string => bool) registeredGithubUsernames;
    address[] public registeredAddresses;

    /* ============ Events ============ */
    event Registered(address contributor, string discordHandle, string githubUsername);
    event ConfirmationVote(address contributor, address voter, uint8 numVotes);
    event ContributorConfirmed(address contributor);

    /* ============ Constructor ============ */

    constructor(uint8 _requiredConfirmations) public {
        requiredConfirmations = _requiredConfirmations;
    }

    /* ============ Functions ============ */

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

        registeredAddresses.push(msg.sender);
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
            contributor.status == Status.CONFIRMED;
            emit ContributorConfirmed(_contributorAddress);
        }
    }
}
