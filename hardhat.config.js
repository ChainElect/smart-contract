require('dotenv').config();
require("@nomicfoundation/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.20", // Update to match OpenZeppelin contracts version
  networks: {
    sepolia: {
      url: API_URL, // Your Alchemy Sepolia URL
      accounts: [`0x${PRIVATE_KEY}`], // Your private key (stored in .env file)
    },
  },
};