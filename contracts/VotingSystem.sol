// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VotingSystem {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this!");
        _;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid address!");
        admin = newAdmin;
    }

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
        mapping(uint256 => Party) parties;
        uint256 partyCount;
    }

    mapping(uint256 => ElectionDetails) public elections;
    uint256 public electionCount;

    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public voterRegistry;

    modifier electionOngoing(uint256 electionId) {
        require(
            block.timestamp >= elections[electionId].startTime &&
            block.timestamp <= elections[electionId].endTime,
            "Election is closed"
        );
        _;
    }

    modifier notVoted(uint256 electionId) {
        require(!hasVoted[electionId][msg.sender], "You have already voted");
        _;
    }

    function createElection(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyAdmin {
        require(_endTime > _startTime, "End time must be after start time");
        
        electionCount++;
        ElectionDetails storage newElection = elections[electionCount];
        newElection.id = electionCount;
        newElection.name = _name;
        newElection.startTime = _startTime;
        newElection.endTime = _endTime;
    }

    function addParty(string memory _partyName, string memory description) public onlyAdmin {
        ElectionDetails storage election = elections[electionCount];
        require(block.timestamp < election.startTime, "Cannot add parties to a started election");
        
        election.partyCount++;
        election.parties[election.partyCount] = Party(election.partyCount, _partyName, 0, description);
    }

    function vote(uint256 partyId) public electionOngoing(electionCount) notVoted(electionCount) {
        ElectionDetails storage election = elections[electionCount];
        require(partyId <= election.partyCount, "Invalid party ID");

        hasVoted[electionCount][msg.sender] = true;
        voterRegistry[electionCount][msg.sender] = partyId;

        election.parties[partyId].voteCount++;
    }

    function getResults(uint256 electionId) public view returns (Party[] memory) {
        ElectionDetails storage election = elections[electionId];
        require(block.timestamp > election.endTime, "Election is still ongoing");

        Party[] memory results = new Party[](election.partyCount);
        for (uint256 i = 1; i <= election.partyCount; i++) {
            results[i - 1] = election.parties[i];
        }

        return results;
    }

    function getElectionParties() public view returns(Party[] memory) {
        ElectionDetails storage election = elections[electionCount];

        
        Party[] memory parties = new Party[](election.partyCount);
        for (uint256 i = 1; i <= election.partyCount; i++) {
            parties[i - 1] = election.parties[i];
        }

        return parties;
    }
}