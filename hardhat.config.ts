import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import '@typechain/hardhat';
import 'hardhat-deploy';

require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";

function mnemonic(): string {
  if ("MNEMONIC" in process.env) {
    return process.env.MNEMONIC ?? ''
  } else {
    console.warn("WARNING: No mnemonic Set");
    return ''
  }
}

const config: HardhatUserConfig =  {
  defaultNetwork: "matic",
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1
      }
    }
  },
  networks: {
    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: {
        mnemonic: mnemonic(),
      },
    },
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
};

export default config;