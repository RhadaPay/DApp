//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContributorRegistry is Ownable{
    uint8 public requiredConfirmations;

    enum Status {NONE, REGISTERED, CONFIRMED}
    struct Contributor {
        Status status;
        uint8 confirmations;
        string discordHandle;
        string githubUsername;
    }
    mapping (address => Contributor) public contributors;
    mapping (string => bool) registeredDiscordHandles;
    mapping (string => bool) registeredGithubUsernames;

    constructor(uint8 _requiredConfirmations) public {
        requiredConfirmations = _requiredConfirmations;
    }

    event Registered(address contributor, string discordHandle, string githubUsername);

    function register(string memory _discordHandle, string memory _githubUsername) public {
        require(contributors[msg.sender].status == Status.NONE, "Account has registered already");
        require(!registeredDiscordHandles[_discordHandle], "Discord handle is already registered");
        require(!registeredGithubUsernames[_githubUsername], "Github username is already registered");

        registeredDiscordHandles[_discordHandle] = true;
        contributors[msg.sender].discordHandle = _discordHandle;

        registeredGithubUsernames[_githubUsername] = true;
        contributors[msg.sender].githubUsername = _githubUsername;

        contributors[msg.sender].status = Status.REGISTERED;
        emit Registered(msg.sender, _discordHandle, _githubUsername);
    }
}
