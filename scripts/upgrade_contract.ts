import { ethers, upgrades } from "hardhat";

async function main() {
  const proxy: string = process.env.PROXY_ADDRESS_CONTRACT || "";

  if (proxy === "") {
    throw Error("Contract proxy address is not set");
  }

  const Contract = await ethers.getContractFactory("Pagamentio");
  console.log("Upgrading contract...");

  const res = await upgrades.upgradeProxy(proxy, Contract);
  console.log(`Contract contract upgraded: ${res.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
