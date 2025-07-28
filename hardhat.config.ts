import 'hardhat-typechain'
import '@nomiclabs/hardhat-ethers'
import '@nomicfoundation/hardhat-chai-matchers'
import '@nomicfoundation/hardhat-foundry'
import dotenv from 'dotenv'
dotenv.config()

const INFURA_API_KEY = process.env.INFURA_API_KEY
const DEFAULT_RPC_URL = process.env.FORK_URL || "https://cloudflare-eth.com"
const MAINNET_RPC_URL = INFURA_API_KEY ? `https://mainnet.infura.io/v3/${INFURA_API_KEY}` : DEFAULT_RPC_URL

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.26',
  settings: {
    viaIR: true,
    evmVersion: 'cancun',
    optimizer: {
      enabled: true,
      runs: 1,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}

export default {
  paths: {
    sources: './contracts',
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      chainId: 1,
      forking: {
        url: MAINNET_RPC_URL,
        blockNumber: 20010000,
      },
    },
    mainnet: {
      url: MAINNET_RPC_URL,
    },
    ropsten: {
      url: `MAINNET_RPC_URL`,
    },
    rinkeby: {
      url: `MAINNET_RPC_URL`,
    },
    goerli: {
      url: `MAINNET_RPC_URL`,
    },
    kovan: {
      url: `MAINNET_RPC_URL`,
    },
    arbitrumRinkeby: {
      url: `https://rinkeby.arbitrum.io/rpc`,
    },
    arbitrum: {
      url: `https://arb1.arbitrum.io/rpc`,
    },
    optimismKovan: {
      url: `https://kovan.optimism.io`,
    },
    optimism: {
      url: `https://mainnet.optimism.io`,
    },
    polygon: {
      url: `MAINNET_RPC_URL`,
    },
    base: {
      url: `https://developer-access-mainnet.base.org`,
    },
    baseGoerli: {
      url: `https://goerli.base.org`,
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  mocha: {
    timeout: 60000,
  },
}
