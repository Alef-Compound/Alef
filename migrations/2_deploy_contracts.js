const constants = require('../config/constants');

var Alef = artifacts.require("./Alef.sol");

module.exports = (deployer) => deployer
                .then( () => deployMainContract(deployer));

function deployMainContract(deployer, network){

  let dai = "0x0";
  let cdai = "0x0";
  let ceth = "0x0";
  /*
  *   network is the parameter passed to truffle
  *   ex: truffle develop --network ropsten
  *
  *   deployer.network is the network used internaly
  *   by truffle
  */
  let activeNetwork = network || deployer.network;

  if (activeNetwork === "develop"){
    dai = constants.DAI_ROPSTEN;
    cdai = constants.CDAI_ROPSTEN;
    ceth = constants.CETH_ROPSTEN;
  } else if (activeNetwork === "ropsten"){
    dai = constants.DAI_ROPSTEN;
    cdai = constants.CDAI_ROPSTEN;
    ceth = constants.CETH_ROPSTEN;
  } else if (activeNetwork === "live") {
    dai = constants.DAI_MAINNET;
    cdai = constants.CDAI_MAINNET;
    ceth = constants.CETH_MAINNET;
  }
  return deployer.deploy(Alef, 
                         dai, //dai
                         cdai,
                         ceth);
}

