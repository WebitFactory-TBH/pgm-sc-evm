import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
import "hardhat-contract-sizer";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import "solidity-coverage";

dotenv.config();

const etherscanKey: string = process.env.ETHERSCAN_KEY || "";
const polygonscanKey: string = process.env.POLYGONSCAN_KEY || "";
const deployAccount: string = process.env.PRIVATE_KEY || "";
const extraAccount1: string = process.env.PRIVATE_KEY2 || "";
const extraAccount2: string = process.env.PRIVATE_KEY3 || "";
const mumbaiUrl: string = process.env.MUMBAI_PROVIDER || "";
const goerliUrl: string = process.env.GOERLI_PROVIDER || "";

const config: HardhatUserConfig = {
  // defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      mainnet: etherscanKey,
      goerli: etherscanKey,
      polygon: polygonscanKey,
      polygonMumbai: polygonscanKey,
    },
  },
  networks: {
    hardhat: {
      accounts: [
        { privateKey: deployAccount, balance: "10000000000000000000000" },
        { privateKey: extraAccount1, balance: "10000000000000000000000" },
        { privateKey: extraAccount2, balance: "10000000000000000000000" },
      ],
      chainId: 1337,
      forking: {
        url: mumbaiUrl,
      },
    },
    mumbai: {
      url: mumbaiUrl,
      accounts: [deployAccount],
      chainId: 80001,
      allowUnlimitedContractSize: true,
      gasPrice: 75000000000,
      gas: 6000000,
    },
    goerli: {
      url: goerliUrl,
      accounts: [deployAccount],
      chainId: 5,
      allowUnlimitedContractSize: true,
      gasPrice: 75000000000,
      gas: 6000000,
    },
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1500,
      },
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: false,
    strict: true,
  },
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

export default config;
