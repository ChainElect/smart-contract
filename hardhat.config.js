/** @type import('hardhat/config').HardhatUserConfig */

require('dotenv').config();
require("@nomicfoundation/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.18", // Ensure this matches your contract version
  networks: {
    sepolia: {
      url: API_URL, // Your Alchemy or Infura Sepolia URL
      accounts: [`0x${PRIVATE_KEY}`], // Your private key (stored in .env file)
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY // Moved outside `networks` to the correct location
  }
};