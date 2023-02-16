var HDWalletProvider = require("@truffle/hdwallet-provider");
var mnemonicPhrase = "shrug soon volume spray embrace space pulp square avoid gather release route";


module.exports = {
  networks: {
    goerli: {
      provider: function() {
        return new HDWalletProvider({
          mnemonic: mnemonicPhrase, 
          providerOrUrl: "wss://goerli.infura.io/ws/v3/12da5d60b4d443ae84a1c985ad34411b", 
          addressIndex: 0,
          numberOfAddresses: 50
        });
      },
      network_id: '*',
      gas: 67200,
      networkCheckTimeoutnetworkCheckTimeout: 10000,
      timeoutBlocks: 200
    },
    development: {
      provider: function() {
        return new HDWalletProvider({
          mnemonic: mnemonicPhrase, 
          providerOrUrl: "http://127.0.0.1:7545",
          addressIndex: 0, 
          numberOfAddresses: 50 
        });
      },
      network_id: '*',
      gas: 6720000,
      networkCheckTimeoutnetworkCheckTimeout: 10000,
      timeoutBlocks: 200
    }
  },
  compilers: {
    solc: {
      version: "^0.4.24"
    }
  }
};