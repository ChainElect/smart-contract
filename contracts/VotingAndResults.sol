// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Structs/ElectionStructs.sol";
import "./Events/ElectionEvents.sol";
import "./PartyManagement.sol";

// Extended contract: VotingAndResults
/// @title Voting and Results Contract
/// @notice Handles the voting 
contract VotingAndResults is PartyManagement {

    /// @notice Vote for a specific party in an election
    function vote(uint256 electionId, uint256 partyId)
        public
        electionOngoing(electionId)
    {
        ElectionDetails storage election = elections[electionId];
        require(!election.hasVoted[msg.sender], "You have already voted");
        require(
            partyId > 0 && partyId <= election.parties.length,
            "Invalid party ID"
        );

        election.parties[partyId - 1].voteCount++;
        election.hasVoted[msg.sender] = true;

        emit Voted(electionId, partyId, msg.sender);
    }

    /// @notice Get results of a closed election
    function getResults(uint256 electionId)
        public
        view
        returns (Party[] memory)
    {
        ElectionDetails storage election = elections[electionId];
        require(
            block.timestamp > election.endTime,
            "Election is still ongoing"
        );

        return election.parties;
    }
}