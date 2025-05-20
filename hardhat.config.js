/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "prague",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    bsc_testnet: {
      url: "https://bsc-testnet.public.blastapi.io",
      chainId: 97,
      accounts: [`329d45df2086825022b2b648fc39ebc4f3edaa0dac7612af86b923f57fd6e26c`],
      gas: 10000000,
    },
    DTC_testnet: {
      url: "http://ec2-54-251-227-86.ap-southeast-1.compute.amazonaws.com:6979",
      chainId: 10086,
      accounts: [`329d45df2086825022b2b648fc39ebc4f3edaa0dac7612af86b923f57fd6e26c`],
    }
  }
};
