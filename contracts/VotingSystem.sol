// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VotingSystem is Ownable {
    struct Party {
        uint256 id;
        string name;
        uint256 voteCount;
        string description;
    }

    struct ElectionDetails {
        uint256 id;
        string name;
        uint256 startTime;
        uint256 endTime;
        Party[] parties;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ElectionDetails) private elections;
    uint256 public electionCount;

    // Constructor to initialize the contract with the deployer as the owner
    constructor() Ownable(msg.sender) {}

    // Filters the opened elections
    modifier electionOngoing(uint256 electionId) {
        require(
            block.timestamp >= elections[electionId].startTime &&
                block.timestamp <= elections[electionId].endTime,
            "Election is closed"
        );
        _;
    }

    // Emits all creations
    event ElectionCreated(
        uint256 indexed electionId,
        string name,
        uint256 startTime,
        uint256 endTime
    );

    // Creating new elections
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

    // Emits all parties added
    event PartyAdded(
        uint256 indexed electionId,
        uint256 indexed partyId,
        string name,
        string description
    );

    // Add party to early elections, which are shut
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

    // Emits all votes
    event Voted(
        uint256 indexed electionId,
        uint256 indexed partyId,
        address indexed voter
    );

    // Vote for a specific party in the election
    function vote(
        uint256 electionId,
        uint256 partyId
    ) public electionOngoing(electionId) {
        ElectionDetails storage election = elections[electionId];
        require(!election.hasVoted[msg.sender], "You have already voted");
        require(
            partyId > 0 && partyId <= election.parties.length,
            "Invalid party ID"
        );

        // Increment the vote count for the party
        election.parties[partyId - 1].voteCount++;

        // Record the vote in the voter registry
        election.hasVoted[msg.sender] = true;

        emit Voted(electionId, partyId, msg.sender);
    }

    // Returns the results of the closed election
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

    // Returns all parties that elections have
    function getElectionParties(
        uint256 electionId
    ) external view returns (Party[] memory) {
        return elections[electionId].parties;
    }

    struct SimpleElectionDetails {
        uint256 id;
        string name;
        uint256 startTime;
        uint256 endTime;
        uint256 partyCount;
    }

    // Returns all open elections
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

    // Adds a function to get full election details by ID
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
}
