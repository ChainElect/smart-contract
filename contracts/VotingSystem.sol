// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./verifier/Verifier.sol"; // Import the Groth16Verifier;
import "./Structs/ElectionStructs.sol";
import "./Events/ElectionEvents.sol";

/// @title Voting System Contract with ZKP Integration
/// @notice This contract allows the creation and management of elections, including voting functionality with ZKP.
contract VotingSystem is Ownable, ElectionEvents {
    Groth16Verifier public verifier; // ZKP Verifier contract

    mapping(uint256 => ElectionDetails) private elections; // Store elections by ID
    uint256 public electionCount; // Total number of elections created

    /// @notice Constructor to initialize the contract with the deployer as the owner
    constructor(address _verifier) Ownable(msg.sender) {
        verifier = Groth16Verifier(_verifier); // Initialize the verifier
    }

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
        uint256 _endTime,
        bytes32 _merkleRoot // Add Merkle root for ZKP verification
    ) public onlyOwner {
        require(_endTime > _startTime, "End time must be after start time");

        electionCount++;
        ElectionDetails storage newElection = elections[electionCount];
        newElection.id = electionCount;
        newElection.name = _name;
        newElection.startTime = _startTime;
        newElection.endTime = _endTime;
        newElection.merkleRoot = _merkleRoot; // Store Merkle root for ZKP

        //emit ElectionCreated(electionCount, _name, _startTime, _endTime);
    }

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

    /// @notice Vote for a specific party in an election using ZKP
    function vote(
        uint256 electionId,
        uint256 partyId,
        uint256 nullifier, // Unique nullifier to prevent double voting
        uint256[2] calldata a, // ZKP proof part A
        uint256[2][2] calldata b, // ZKP proof part B
        uint256[2] calldata c, // ZKP proof part C
        uint256[1] calldata pubSignals // Public signals (Merkle root and nullifier)
    ) public electionOngoing(electionId) {
        ElectionDetails storage election = elections[electionId];

        // Ensure the voter hasn't already voted
        require(!election.nullifiers[nullifier], "Already voted");

        // Ensure the party ID is valid
        require(
            partyId > 0 && partyId <= election.parties.length,
            "Invalid party ID"
        );

        // Verify the ZKP
        require(verifier.verifyProof(a, b, c, pubSignals), "Invalid ZKP proof");

        // Ensure the Merkle root in the proof matches the election's Merkle root
        require(
            pubSignals[0] == uint256(election.merkleRoot),
            "Invalid Merkle root"
        );

        // Ensure the nullifier in the proof matches the provided nullifier
        //require(pubSignals[1] == nullifier, "Invalid nullifier");

        // Record the vote
        election.parties[partyId - 1].voteCount++;
        election.nullifiers[nullifier] = true; // Mark nullifier as used

        emit Voted(electionId, partyId, msg.sender);
    }

    /// @notice Returns all parties in an election
    function getElectionParties(
        uint256 electionId
    ) external view returns (Party[] memory) {
        return elections[electionId].parties;
    }

    /// @notice Get results of a closed election
    function getResults(
        uint256 electionId
    ) public view returns (Party[] memory) {
        ElectionDetails storage election = elections[electionId];
        require(
            block.timestamp > election.endTime,
            "Election is still ongoing"
        );

        return election.parties;
    }

    /// @notice Get details of an election by ID
    function getElectionDetails(
        uint256 electionId
    )
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
}
