/** @type import('hardhat/config').HardhatUserConfig */

require('dotenv').config();
require("@nomicfoundation/hardhat-ethers");

//require("@nomicfoundation/hardhat-toolbox");
//require("@nomiclabs/hardhat-ethers");

const {API_URL, PRIVATE_KEY} = process.env;

module.exports = {
  solidity: "0.8.18", // Ensure this matches your contract version
  networks: {
    sepolia: {
      url: API_URL, // Your Alchemy Sepolia URL
      accounts: [`0x${PRIVATE_KEY}`], // Your private key (stored in .env file)
    },
  },
};

/*require("@nomiclabs/hardhat-waffle"); // Optional, for testing and contract interactions

module.exports = {
  solidity: "0.8.18", // Use the Solidity version that matches your contract
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/89jSnaKWM_MxViGgmQyrTyS4xHMzXukz", // Your Alchemy Sepolia URL
      accounts: [`0x${process.env.PRIVATE_KEY}`], // Your private key (stored in .env file)
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // Optional, for verifying contracts on Etherscan
  },
  mocha: {
    timeout: 20000, // Set a reasonable timeout for testing
  },
};
*/