import React, { Component } from "react";
import AlefContract from "./contracts/Alef.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { supplierInfos: {
                            status: false,
                            supplierOffersCounter: 0,
                            daiAmount: 0,
                            cDaiAMount: 0,
                            etherAmount: 0,
                            cEtherAmount: 0
                          },
            web3: null,
            accounts: null,
            contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = AlefContract.networks[networkId];
      const instance = new web3.eth.Contract(
        AlefContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.getSupplierInfos);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  getSupplierInfos = async () => {
    const { accounts, contract } = this.state;

    // // Stores a given value, 5 by default.
//    await contract.methods.setSupplier(accounts[0]).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    let response;
    try{
       response = await contract.methods.getSupplierInfos(accounts[0]).call();
      console.log(response);

      // Update state with the result.
      var supplierInfos = {...this.state.supplierInfos};
      supplierInfos.status = response.status;
      supplierInfos.supplierOffersCounter = response.supplierOffersCounter;
      supplierInfos.daiAmount = response.daiAmount;
      supplierInfos.cDaiAmount = response.cDaiAmount;
      supplierInfos.etherAmount = response.etherAmount;
      supplierInfos.cEtherAmount = response.cEtherAmount;
      this.setState({supplierInfos})
    } catch(err){
      console.log(err);
      console.log(response);
    }

  };

  setSupplierClick = async () => {
    const { accounts, contract } = this.state;
    try{
      let res = await contract.methods.setSupplier(accounts[0]).send({ from: accounts[0] });
      this.getSupplierInfos();
      console.log(res);
    } catch (err){
      console.log(err);
    }
  }


  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <h2>Alef Example</h2>
        <p>
          Let set a new supplier with our current address.
        </p>
        <button onClick={this.setSupplierClick}>
          Set supplier
        </button>
        <p>
          This is the value of you current supplier variable.
        </p>
        <div>The status value is: {this.state.supplierInfos.status.toString()}</div>
        <div>The supplierOffersCounter value is: {this.state.supplierInfos.supplierOffersCounter}</div>
        <div>The daiAmount value is: {this.state.supplierInfos.daiAmount}</div>
        <div>The cDaiAmount value is: {this.state.supplierInfos.cDaiAmount}</div>
        <div>The etherAmount value is: {this.state.supplierInfos.etherAmount}</div>
        <div>The cEtherAmount value is: {this.state.supplierInfos.cEtherAmount}</div>
      </div>
    );
  }
}

export default App;
