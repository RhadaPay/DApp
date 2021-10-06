pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContributorRegistry.sol";
import "./RoundVoting.sol";

contract DAORegistry is Ownable {
    /* ============ Datatypes ============ */
    struct DAO {
        address daoAddress;
        string daoName;
        bool approved; // my idea for this is that a member of Rhada can change the value of this field to approve a DAO application
        address roundManager; // take out
        address[] admins;
        address[] members;         // a list of members of the DAO. Should this be included here?
    }

    /* ============ State Variables ============ */
    // List of DAOs
    DAO[] public DAOs;
    // list of Contributors in a DAO (will have to think of a method to expose this list)
    Contributor[] contributors;
    // The streaming instance of a DAO
    // PaymentStream public stream;
    // The voting rounds of a DAO
    RoundVoting public round;
    // The registry of a DAO
    ContributorRegistry public registry;

    /**
        Constructor Function
        @param streamAddress The contract address used to manage payment streams.
        @param roundAddress The contract address where round voting details can be found.
        @param registryAddress The contract address where registered contributors and confirmed
                                members can be found.
     */
    constructor (address streamAddress, address roundAddress, address registryAddress) {
        // stream = PaymentStream(streamAddress);
        round = RoundVoting(roundAddress);
        registry = ContributorRegistry(registryAddress);
    }

    /* Private Functions */ 

    function registerDAO() {

    }

    function updateStream() {

    }

    function what daos am I in() {

    }

    /**
        This is a validation check for when a user selects a DAO in the front end to ensure they are actually a member of the DAO.
        Another option to do this is to emit a memberlist in the registry and check that member list for x address.
     */
    function isMemberOf() {

    }


}