const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    mainnet: {
      provider: () =>
        new HDWalletProvider(
          process.env.MNEMONIC,
          "https://mainnet.infura.io/v3/" + process.env.INFURA_PROJECT_ID
        ),
      network_id: "1",
      skipDryRun: true,
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          process.env.MNEMONIC,
          "https://ropsten.infura.io/v3/" + process.env.INFURA_PROJECT_ID
        ),
      network_id: "3",
      networkCheckTimeout: "30000",
      skipDryRun: true,
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          process.env.MNEMONIC,
          "https://rinkeby.infura.io/v3/" + process.env.INFURA_PROJECT_ID
        ),
      network_id: "4",
      networkCheckTimeout: "30000",
      skipDryRun: true,
    },
    mumbai: {
      provider: () =>
        new HDWalletProvider(
          process.env.MNEMONIC,
          "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_PROJECT_ID
        ),
      network_id: "80001",
    },
  },
  compilers: {
    solc: {
      version: "0.6.5",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
  },
  plugins: ["truffle-plugin-verify"],
};
