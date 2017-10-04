var exchange = artifacts.require("./Exchange.sol");
var AToken = artifacts.require("./AToken.sol");
var usr = artifacts.require("./UserRegistration.sol");
var CToken = artifacts.require("./CToken.sol");
var Asset = artifacts.require("./AssetRegistration.sol");
var TxReg = artifacts.require("./TxRegister.sol");

module.exports = function(deployer) {
  deployer.deploy(usr);
  deployer.deploy(Asset); 
  deployer.deploy(CToken); 
  deployer.link(Asset,AToken);
  deployer.deploy(AToken);
  deployer.deploy(TxReg);
};