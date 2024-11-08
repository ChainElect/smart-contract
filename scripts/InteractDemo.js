require('dotenv').config();
const { API_KEY, PRIVATE_KEY, CONTRACT_ADDRESS } = process.env;

// contracts/admin.js
const { ethers } = require('ethers');
const { wallet } = require('../config/provider');

const adminContractAddress = CONTRACT_ADDRESS; // Replace with deployed Admin contract address

const contractData = require("../artifacts/contracts/VotingSystem.sol/VotingSystem.json");
const adminAbi = contractData.abi;
const adminContract = new ethers.Contract(adminContractAddress, adminAbi, wallet);

async function main() {
    try {
        // Retrieve the admin address from the contract
        const admin = await adminContract.admin();
        console.log("The admin is:", admin);
    } catch (error) {
        console.error("Error fetching admin:", error);
    }
}

// Execute main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error in script execution:", error);
    process.exit(1);
  });

