import { ethers, upgrades } from "hardhat";

async function main() {
  const Contract = await ethers.getContractFactory("Pagamentio");

  const tokenContract = await upgrades.deployProxy(Contract, [], {
    initializer: "initialize",
  });

  console.log(`Contract contract deployed to ${tokenContract.address}`);
  // console.log(
  //   `Implementation contract deployed to ${await upgrades.erc1967.getImplementationAddress(
  //     tokenContract.address
  //   )}`
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
