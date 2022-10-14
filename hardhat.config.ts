import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const { ALCHEMY_API_KEY, API_URL, PRIVATE_KEY, GOERLI_ETHERSCAN_API_KEY } =
  process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: API_URL,
      accounts: [PRIVATE_KEY as string],
    },
  },
  etherscan: {
    apiKey: {
      goerli: GOERLI_ETHERSCAN_API_KEY as string,
    },
  },
};

export default config;
