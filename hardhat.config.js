require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('hardhat-contract-sizer');


module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0"
      },
      {
        version: "^0.8.0"
      },
      {
        version: "0.8.1"
      },
      {
        version: "^0.8.1"
      }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    
  },
  networks: {
    rinkeby: {
      url: 'https://speedy-nodes-nyc.moralis.io/147a3d9c829dca95b14abc55/eth/rinkeby',
      accounts: ["0x34d6bc217ed66500505303296fcbce22e1c3a9f094836f422611c58e3edbb40f", 
    ]
    }
  }
};