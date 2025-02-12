// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @notice Struct for storing party details
struct Party {
    uint256 id;
    string name;
    uint256 voteCount;
    string description;
}

/// @notice Struct for storing election details
struct ElectionDetails {
    uint256 id;
    string name;
    uint256 startTime;
    uint256 endTime;
    bytes32 merkleRoot; // Added for ZKP
    Party[] parties;
    mapping(uint256 => bool) nullifiers; // Added for ZKP
}


/// @notice Struct for simplified election details
struct SimpleElectionDetails {
    uint256 id;
    string name;
    uint256 startTime;
    uint256 endTime;
    uint256 partyCount;
}
