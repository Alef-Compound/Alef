const alef = artifacts.require("Alef");


const cEthContractAddress = "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5";
const daiContractAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const cDaiContractAddress = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643";


module.exports = function(deployer) {

  deployer.deploy (alef, daiContractAddress,cDaiContractAddress,cEthContractAddress);
};
