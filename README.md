# AssetManagerV2

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

### Setup

- Rename the .env.example file to .env file (the .env file is gitignored).
- Add the necessary values to the .env file

```shell
API_URL="Your alchemy api url here"
PRIVATE_KEY="your testing private key:funded"
ALCHEMY_API_KEY="Your alchemy api key"
GOERLI_ETHERSCAN_API_KEY="Your etherscan api key"
```

### Deploy and Verify on Etherscan

```shell
yarn install
yarn run deploy --network goerli
yarn run verify --network goerli "AssetManagerV2 contract address"
```
