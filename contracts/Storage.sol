pragma solidity >=0.6.0 <0.7.0;

abstract contract Erc20 {
  function approve(address, uint)virtual external returns (bool);
  function transfer(address, uint)virtual external returns (bool);
  function balanceOf(address owner)virtual external view returns (uint256 balance);
  function transferFrom(address sender, address recipient, uint256 amount) virtual external returns (bool);
}

abstract contract CErc20 {
  function approve(address, uint)virtual external returns (bool);
  function mint(uint)virtual external returns (uint);
  function balanceOfUnderlying(address account)virtual external returns (uint);
  function totalReserves()virtual external returns (uint);
  function transfer(address dst, uint amount) virtual external returns (bool);
  function exchangeRateCurrent() virtual external returns (uint);
}

abstract contract CEth {
  function mint()virtual external payable;
  function balanceOfUnderlying(address account)virtual external returns (uint);
  function balanceOf(address owner)virtual external view returns (uint256 balance);
  function transfer(address dst, uint256 amount)virtual external returns (bool success);
  function transferFrom(address src, address dst, uint wad)virtual external returns (bool);
  function redeem(uint redeemTokens) virtual external returns (uint);
  function exchangeRateCurrent() virtual external returns (uint);
  function approve(address, uint)virtual external returns (bool);
}

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

import "./compound/IERC20.sol";
import './compound/ComptrollerInterface.sol';
import './compound/CTokenInterface.sol';

import "./Safe/Ownable.sol";
import "./Safe/Pausable.sol";

contract Storage is Ownable, Pausable {

  using SafeMath for uint256;

  address internal daiContractAddress; // Contains Dai SmartContract address || 0x6B175474E89094C44Da98b954EedeAC495271d0F ||
  address internal cDaiContractAddress; // Contains cDai SmartContract address || 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 ||
  address internal cEthContractAddress; // Contains eEth SmartContract address || 0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5 ||


  uint256 internal contractEtherBalance; // Total amount of Ether in contract
  uint256 internal contractDaiBalance; // Total amount of Dai in contract
  uint256 internal contractCethBalance; // Total amount of cEther in contract
  uint256 internal contractCdaiBalance; // Total amount of cDai in contract


   uint256 public uniqueOfferId; // global offers counter

  //INTEREST EVENTS//
  event newInterest (address _interestOwner, uint256 _uniqueOfferId);
  event interestDeleted (address _interestOwner, uint256 _uniqueOfferId);

  //PROVIDER EVENTS//
  event newProvider (address _provider); // emit 'new provider' address
  event newCommittment (address _provider, uint256 offersCounter); // emits address provider and the global offer id
  event purchase (bytes32 hashCheck,address _supplier, uint256 _offerId);
  event sponsorshipDeleted (address _provider, uint256 _providerSponsorshipCounter);
  event interestEnabled (bytes32 _hashCheck); //emit addr beneficiary and global offer id

  //SUPPLIER EVENTS//
  event newSupplier (address _supplier); // emit 'new supplier' address
  event newOffer (address _supplier, uint256 _id); // emit the id of the offer just created
  event offerChange (uint256 _offerId); // emit offer id of 'offer' changed



  //MICROFEE FOR SUPPLIER AND INTEREST
  modifier fee {
      require (msg.value >= 100 szabo, 'missing fee');
      _;
  }


  modifier isSupplier {
      require (supplier[msg.sender].status == true, "not an active supplier");
      _;
  }


  modifier isProvider {
      require (provider[msg.sender].status == true, "msg.sender is not an active provider");
      _;
  }


  struct Supplier {
      bool status;
      uint256 supplierOffersCounter; // this id is used internally, never decreases
      uint256 daiAmount;
      uint256 cDaiAmount;
      uint256 etherAmount;
      uint256 cEtherAmount;
      mapping (uint256 => Offers) offers;
  }

  mapping (address => Supplier) public supplier;

  struct Offers {

      bool status;
      uint256 offerId; // this id is the global one
      uint256 price; // I am going to use dai for now, we can change it later
  }



  struct Provider {
    // true if provider
    bool status;
    // provider ether balance
    uint256 etherBalance;
    // provider cEth balance
    uint256 cEtherBalance;
    // provider Dai balance
    uint256 daiBalance;
    // provider cDai balance
    uint256 cDaiBalance;
  }

  mapping (address => Provider) public provider;



  struct Interests {
    address provider; // when a provider pays for this interest, the provider address is set and the user entitled to use the service

    address interestOwner; // the one who registered the interest
    uint256 interestId;  // this id is the global one
  }

  mapping (bytes32 => Interests) public interest; // an user can subscribe to more offers because it mapped with user HASHING address + uniqueOfferId








  // GETTER METHODS - PROVIDER STRUCT

  function getProviderEtherBalance (address _provider) public view returns (uint256) {
      //@-> return Ether balance in provider struct
      return provider[_provider].etherBalance;
  }

  function getProviderCetherBalance (address _provider) public view returns (uint256) {
      //@-> return cEther balance in provider struct
      return provider[_provider].cEtherBalance;
  }

  function getProviderDaiBalance (address _provider) public view returns (uint256) {
      //@-> return Dai balance in provider struct
      return provider[_provider].daiBalance;
  }

  function getProviderCdaiBalance(address _provider) public view returns (uint256) {
      //@-> return cDai balance in provider struct
      return provider[_provider].cDaiBalance;
  }

  function getProviderStatus (address _provider) public view returns (bool) {
      //@-> return status in provider struct
      return provider[_provider].status;
  }





  //GETTER METHODS SUPPLIER STRUCT

  function getOfferBySupplier (address _supplier, uint256 _supplierOffersCounter) public view returns (bool,uint256) {
    // return offer details of a given _supplier

    // @-> Dev uint256 supplierOffersCounter tells how many projects have been offered by this _supplier

    // _supplierOffersCounter id MUST be the internal id in struct Supplier

    return (
        supplier[_supplier].offers[_supplierOffersCounter].status,
        supplier[_supplier].offers[_supplierOffersCounter].price
        );
  }


  function getSupplierOffersCounter (address _supplier) public view returns (uint256) {

    // returns the total amount of offers created.
    return ( supplier[_supplier].supplierOffersCounter);

  }


  function getOfferStatus (address _supplier, uint256 _supplierOffersCounter) public view returns (bool) {


      // @-> Dev uint256 providerOffersCounter tells how many projects have been offered by this _supplier
      // offer id MUST be the internal id in struct Supplier


      return (supplier[_supplier].offers[_supplierOffersCounter].status);
  }






  //@-> Dev   those are the setters for compound and erc20 token addresses
  //@-> Notice! contract must be paused to allow setting a new address
  //            onlyOwner restricted

  function setDAIcontractAddress (address _newDAIaddress) public onlyOwner whenPaused returns (address){
    daiContractAddress = _newDAIaddress;
    return daiContractAddress;
  }

  function setCDAIcontractAddress (address _newCDAIaddress) public onlyOwner whenPaused returns (address){
    cDaiContractAddress = _newCDAIaddress;
    return cDaiContractAddress;
  }

  function setCETHcontractAddress (address _newCETHaddress) public onlyOwner whenPaused returns (address){
    cEthContractAddress = _newCETHaddress;
    return cEthContractAddress;
  }


}
