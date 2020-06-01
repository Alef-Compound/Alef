var Alef = artifacts.require("./Alef.sol");

module.exports = (deployer) => deployer
                .then( () => deployMainContract(deployer));

function deployMainContract(deployer){
  return deployer.deploy(Alef, 
                         "0x6B175474E89094C44Da98b954EedeAC495271d0F",
                         "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643",
                         "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5");
}