# BHack EVM SC

## Folder structure

- `/contracts` - the smart contract code (written in solidity)
- `/scripts` - the deployment and upgrade scripts for the contracts

There are also two more important files

- `hardhat.config.ts` - the configuration file for hardhat - compilation settings, deployment and network settings
- `.env` - various envirnment variables used by the application. Use `.env.example` for reference

## Contract deployment

The contracts can be deployed on any network configured in `hardhat.config.ts`: __localhost__, __mumbai__, __goerli__. In some cases (slow blockchains), the deployment script might time out, but the contract could still be eventually deployed. To compile and deploy a smartcontract use the following command:

```bash
# Token contract
npx hardhat run --network <your-network> scripts/deploy_contract.ts
```

To deploy the contract on the __localhost__ (local testing network) you must first run (in a separate terminal) the following command:

```bash
npx hardhat node
```

## Contract upgrades

The contracts are implemented as upgradeable contracts, which means they will use a proxy for all the requests. The contract addresses stored in the `.env` files are actually the addresses of the proxy contracts. Also, when calls are made to get/modify data on the contract, we use the proxy, which will then forward the request to the actual contract implementation.

To upgrade the contract, after we ensured the right addresses are set up in `env`, we run the following commands:

```bash
# Token contract
npx hardhat run --network <your-network> scripts/upgrade_contract.ts
```
