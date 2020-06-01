const Alef = artifacts.require("./Alef.sol");

contract("Alef initialization", accounts => {

  it("Contract should be setup with Compound address", async () => {
    const AlefInstance = await Alef.deployed();
    let value = await AlefInstance.initialized();
    assert(value === true, "The initialized contract variable should be set to true.");
  });
});
