// may change the contract constructor to get address and which will be sent here
async function main() {
    const VotingSystem = await ethers.getContractFactory("VotingSystem");

    const voting_system = await VotingSystem.deploy();

    console.log("Contract is deployed to address: ", voting_system.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
