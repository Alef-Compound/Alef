pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "./Storage.sol";


contract Alef is Storage {


  using SafeMath for uint256;


  constructor (address _daiContractAddress, address _cDaiContractAddress, address _cEthContractAddress) public {
    // verify parameters
    require(Erc20(_daiContractAddress).approve(address(this), 0),"dai contract did not answer");
    require(CErc20(_cDaiContractAddress).approve(address(this), 0),"cDai contract did not answer");
    require(CEth(_cEthContractAddress).approve(address(this), 0),"cEth contract did not answer");

    daiContractAddress = _daiContractAddress;
    cDaiContractAddress = _cDaiContractAddress;
    cEthContractAddress = _cEthContractAddress;
  }



  /* SUPPLIERS

  Suppliers supply goods && || services
  Only the contract owner can set a new supplier. <-- should we just allow anyone to register by paying a small fee?
                                                      a small fee avoid spams and does not hurt the user experience.

  Suppliers activate offers, they can set a price and disable them.
  Each supplier can set as much offers it wants.
  Each offer has a unique id "offersCounter".
  Each offer published by an address is saved in  -->  supplier[msg.sender].offers[]
  you need an id to access the offer internally.
  The ID you must remember to use is supplierOffersCounter -->  supplier[msg.sender].supplierOffersCounter,
  this will increase by (1) each time a supplier sets a new offer
  */


  function setSupplier (address _supplier) public onlyOwner {

    require (supplier[_supplier].status == false, "is already supplier");
    supplier[_supplier].status = true;
    emit newSupplier(_supplier);
  }


  function setOffer (uint256 _price) public payable isSupplier fee {

    // setting a new offer uses two ids:
    // 1- the supplierOffersCounter id which keeps the totala mount of offers uploaded by the supplier
    // 2- the global offer id which is gonna be set in the offer itself


    supplier[msg.sender].offers[supplier[msg.sender].supplierOffersCounter].status = true;
    supplier[msg.sender].offers[supplier[msg.sender].supplierOffersCounter].offerId = uniqueOfferId; // we have saved the unique global id for this offer.
    supplier[msg.sender].offers[supplier[msg.sender].supplierOffersCounter].price = _price;

    supplier[msg.sender].supplierOffersCounter = supplier[msg.sender].supplierOffersCounter.add(1); // Increase id in offer struct
    uniqueOfferId = uniqueOfferId.add(1); // Increase global id counter

    emit newOffer(msg.sender,supplier[msg.sender].offers[uniqueOfferId].offerId);
  }


  function disableOffer (uint256 _supplierOffersCounter) public isSupplier {

      // set offer [id] status to false
      // _supplierOffersCounter must be the internal counter of struct Supplier

      require (supplier[msg.sender].offers[_supplierOffersCounter].status == true,'no such offer');
      supplier[msg.sender].offers[_supplierOffersCounter].status = false;
      emit offerChange (_supplierOffersCounter);
  }


  function activateOffer (uint256 _supplierOffersCounter) public isSupplier {

      // set offer [id] status to true
      // _supplierOffersCounter must be the internal counter of struct Supplier

      require (supplier[msg.sender].offers[_supplierOffersCounter].status == true,'no such offer');
      supplier[msg.sender].offers[_supplierOffersCounter].status = true;
      emit offerChange (_supplierOffersCounter);
  }


  function setPrice (uint256 _supplierOffersCounter, uint256 _price) public isSupplier {

      // set a new price for offer id
      // _supplierOffersCounter must be the internal counter of struct Supplier


      require (supplier[msg.sender].offers[_supplierOffersCounter].status == true,'no such offer');
      supplier[msg.sender].offers[_supplierOffersCounter].price = _price;
      emit offerChange (_supplierOffersCounter);
  }


  function getAllOffersBySupplier (address _supplier) public view returns (uint256 [] memory) {

      // returns an array of GLOBAL offers IDs for a given supplier
      uint256 totalOffers = getSupplierOffersCounter (_supplier);
      uint256 [] memory result = new uint256 [] (totalOffers);
      uint8 i;

      for (i=0;i<totalOffers;i++){
          result[i] = supplier[_supplier].offers[i].offerId;
      }

      return result;
  }





  /* INTERESTS
  Anyone can create an interest.
  It has a creator = address interestOwner
  It keeps the global interest id = interestId
  */

  function setInterest (uint256 _uniqueOfferId) public payable fee {

    bytes32 hashCheck = keccak256(abi.encodePacked(msg.sender,_uniqueOfferId));

    require (interest[hashCheck].interestOwner == address(0),'interest already set');

    interest[hashCheck].interestOwner = msg.sender;
    interest[hashCheck].interestId = _uniqueOfferId;

    emit newInterest (msg.sender,_uniqueOfferId);
  }


  function deleteInterest (uint256 _uniqueOfferId) public {

    bytes32 hashCheck = keccak256(abi.encodePacked(msg.sender,_uniqueOfferId));
    require (interest[hashCheck].interestOwner == msg.sender,'must be interest owner');

    delete (interest[hashCheck]);

    emit interestDeleted (msg.sender,_uniqueOfferId);
  }





   /* PROVIDERS
   Providers provide liquidity.
   A provider deposits money and can both invest of purchase directly.
   Only the contract owner can set providers (to consider too)

   Once buys an offer the interest, other than moving money, struct
   Interests will populate:

   interest.[hash(beneficiary address + global offer id)].provider.
   Once provider is set the interest can be 'used' by the interestOwner.

   need to code all the deposit withdraw stuff and implementing compound.
   shoudn't be hard
   */

   function setProvider (address _provider) public onlyOwner {
     require (provider[_provider].status == false, "is already provider");
     provider[_provider].status = true;
     emit newProvider(_provider);
   }


   function buyOffer (address _beneficiary, address _supplier, uint256 _supplierOffersCounter) public isProvider { // WORKS WITH DAI AT THE MOMENT, CAN BE CHANGED OR CODE MORE FUNCTIONS

    // _supplierOffersCounter MUST be the supplierOffersCounter variable in Supplier struct


    require (supplier[_supplier].offers[_supplierOffersCounter].status == true, 'offer id not valid'); // must be an active offer

    require (provider[msg.sender].daiBalance >= supplier[_supplier].offers[_supplierOffersCounter].price, 'insufficient balance'); // dai balance of provider > price

    // decreasing dai balance from PROVIDER

    provider[msg.sender].daiBalance = provider[msg.sender].daiBalance.sub(supplier[_supplier].offers[_supplierOffersCounter].price);

    // increasing dai balance of SUPPLIER

    supplier[_supplier].daiAmount = supplier[_supplier].daiAmount.add(supplier[_supplier].offers[_supplierOffersCounter].price);

    bytes32 hashCheck = activateInterest (_beneficiary, supplier[_supplier].offers[_supplierOffersCounter].offerId);

    require (hashCheck[0] != 0); // must not be empty hash


    emit purchase (hashCheck,_supplier,_supplierOffersCounter);

  }


  function activateInterest (address _beneficiary, uint256 _offerId) private returns (bytes32){

    // hash the _beneficiary address and the uniqueOfferId to generate the id for struct interest

    bytes32 hashCheck = keccak256(abi.encodePacked(_beneficiary,_offerId));

    require (interest[hashCheck].provider == address(0),'interest already active');

    interest[hashCheck].provider = msg.sender;

    return hashCheck;
  }


}
