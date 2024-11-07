// config/provider.js
const { ethers } = require('ethers');
require('dotenv').config();

const { API_KEY, PRIVATE_KEY } = process.env;

const alchemyProvider = new ethers.AlchemyProvider('sepolia', API_KEY);
const wallet = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

module.exports = { wallet };