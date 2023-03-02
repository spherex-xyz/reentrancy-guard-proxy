/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-truffle5");

const fs = require('fs');
const path = require('path');

for (const f of fs.readdirSync(path.join(__dirname, 'hardhat'))) {
  require(path.join(__dirname, 'hardhat', f));
}

module.exports = {
  solidity: "0.8.17",
};
