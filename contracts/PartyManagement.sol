// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Structs/ElectionStructs.sol";
import "./Events/ElectionEvents.sol";
import "./ElectionManagement.sol";

// Extended contract: PartyManagement
/// @title Party Management Contract
/// @notice Handles the adding of parties and reading their details
contract PartyManagement is ElectionManagement {

    /// @notice Add a party to an election
    function addParty(
        uint256 electionId,
        string memory _partyName,
        string memory _description
    ) public onlyOwner {
        ElectionDetails storage election = elections[electionId];
        require(
            block.timestamp < election.startTime,
            "Cannot add parties to a started election"
        );

        election.parties.push(
            Party({
                id: election.parties.length + 1,
                name: _partyName,
                voteCount: 0,
                description: _description
            })
        );

        emit PartyAdded(
            electionId,
            election.parties.length,
            _partyName,
            _description
        );
    }

    // @notice Returns all parties that elections have
    function getElectionParties(uint256 electionId)
        external
        view
        returns (Party[] memory)
    {
        return elections[electionId].parties;
    }
}