import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import '@typechain/hardhat';
import 'hardhat-deploy';
import "@nomiclabs/hardhat-etherscan";

require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";

require("dotenv").config();

const config: HardhatUserConfig =  {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    mumbai: {
      url: process.env.MUMBAI_RPC,
      chainId: 80001,
      accounts: [ process.env.PRIVATE_KEY as string]
    }
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1
      }
    }
  },  
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_KEY
  },
  namedAccounts: {
    deployer: 0,
    host: {
      "mumbai": '0xEB796bdb90fFA0f28255275e16936D25d3418603'
    },
    cfa: {
      "mumbai": '0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873'
    },
    acceptedToken: {
      "mumbai": '0x5D8B4C2554aeB7e86F387B4d6c00Ac33499Ed01f'
    }
  },
};

export default config;