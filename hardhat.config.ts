import * as dotenv from 'dotenv';
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "hardhat-gas-reporter"

dotenv.config();

const { SEPOLIA_URL, PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.21",
    settings: {
        viaIR: true,
        optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
//   networks: {
//     hardhat: {
//       forking: {
//         // provide a network url where the P256Verifier library exists
//         // ref: https://github.com/daimo-eth/p256-verifier
//         url: SEPOLIA_URL!
//       },
//       accounts: [{
//         privateKey: PRIVATE_KEY!,
//         balance: "10000000000000000000000" // 10000 ETH
//       }]
//     }
//   }
};

export default config;
