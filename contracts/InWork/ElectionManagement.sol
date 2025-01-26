// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../Structs/ElectionStructs.sol";
import "../Events/ElectionEvents.sol";

// Base contract: ElectionManagement
/// @title Election Management Contract
/// @notice Handles the creation and basic details of elections. Return the elections based on the state, if the are oped or not
contract ElectionManagement is Ownable,  ElectionEvents{

    /// @notice Constructor to initialize the contract with the deployer as the owner
    constructor() Ownable(msg.sender) {}

    mapping(uint256 => ElectionDetails) internal elections;
    uint256 public electionCount;

    /// @notice Modifier to ensure the election is ongoing
    modifier electionOngoing(uint256 electionId) {
        require(
            block.timestamp >= elections[electionId].startTime &&
                block.timestamp <= elections[electionId].endTime,
            "Election is closed"
        );
        _;
    }

     /// @notice Create a new election
    function createElection(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyOwner {
        require(_endTime > _startTime, "End time must be after start time");

        electionCount++;
        ElectionDetails storage newElection = elections[electionCount];
        newElection.id = electionCount;
        newElection.name = _name;
        newElection.startTime = _startTime;
        newElection.endTime = _endTime;

        emit ElectionCreated(electionCount, _name, _startTime, _endTime);
    }


     /// @notice Get all closed elections
    function getClosedElection()
        public
        view
        returns (SimpleElectionDetails[] memory)
    {
        uint256 closedCount = 0;

        for (uint256 i = 1; i <= electionCount; i++) {
            if (block.timestamp > elections[i].endTime) {
                closedCount++;
            }
        }

        SimpleElectionDetails[]
            memory closedElections = new SimpleElectionDetails[](closedCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= electionCount; i++) {
            if (block.timestamp > elections[i].endTime) {
                ElectionDetails storage election = elections[i];
                closedElections[index] = SimpleElectionDetails(
                    election.id,
                    election.name,
                    election.startTime,
                    election.endTime,
                    election.parties.length
                );
                index++;
            }
        }

        return closedElections;
    }

     /// @notice Get all ongoing elections
    function getAllOngoingElections()
        public
        view
        returns (SimpleElectionDetails[] memory)
    {
        uint256 ongoingCount = 0;

        for (uint256 i = 1; i <= electionCount; i++) {
            if (
                block.timestamp >= elections[i].startTime &&
                block.timestamp <= elections[i].endTime
            ) {
                ongoingCount++;
            }
        }

        SimpleElectionDetails[]
            memory ongoingElections = new SimpleElectionDetails[](ongoingCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= electionCount; i++) {
            if (
                block.timestamp >= elections[i].startTime &&
                block.timestamp <= elections[i].endTime
            ) {
                ElectionDetails storage election = elections[i];
                ongoingElections[index] = SimpleElectionDetails(
                    election.id,
                    election.name,
                    election.startTime,
                    election.endTime,
                    election.parties.length
                );
                index++;
            }
        }

        return ongoingElections;
    }

     /// @notice Get details of an election by ID
    function getElectionDetails(uint256 electionId)
        public
        view
        returns (
            uint256 id,
            string memory name,
            uint256 startTime,
            uint256 endTime,
            Party[] memory parties
        )
    {
        ElectionDetails storage election = elections[electionId];
        return (
            election.id,
            election.name,
            election.startTime,
            election.endTime,
            election.parties
        );
    }
}
