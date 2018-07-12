var VirtLotto = artifacts.require("VirtLotto");

module.exports = function(deployer) {
  deployer.deploy(VirtLotto, web3.toWei('1', 'finney'), 5);
}