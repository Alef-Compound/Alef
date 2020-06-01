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
    initialized = true;
  }


  function addSponsor(address _sponsor) public onlyOwner {

    // add a new sponsor

    require (sponsors[_sponsor].status != true, "already a sponsor");

    sponsors[_sponsor].status = true;

    emit SponsorAction(_sponsor, 'added');
  }



  function enableSponsor(address _address) public onlyOwner {

    // enable a sponsor
    //@-> require: _sponsor status == not active
    //@-> emits: address enabled and action as string

    require (sponsors[_address].status == false,"already enabled");

    sponsors[_address].status = true;

    emit SponsorAction(_address, "enabled");

  }


  function disableSponsor(address _address) public onlyOwner {

    // disable sponsor
    //@-> require: _sponsor != owner and _sponsor status == active
    //@-> emits: address disabled and action as string
    //@-> notice: _sponsor is not cancelled. Sponsor balance remains saved

    require (_address != owner && sponsors[_address].status == true,"already disabled") ;

    sponsors[_address].status = false;

    emit SponsorAction(_address, 'disabled');
  }



  function sponsorEthDeposit() public payable whenNotPaused {

    // increase sponsor balance

    require (msg.value > 0,"cannot deposit 0");

    sponsors[msg.sender].etherBalance = sponsors[msg.sender].etherBalance.add(msg.value);

    emit NewDeposit(msg.sender, msg.value);
  }


  function fundSponsor (address _sponsor) public payable whenNotPaused {

    // anyone can fund a sponsor

    require (sponsors[_sponsor].status == true,"sponsor does not exist");

    sponsors[_sponsor].etherBalance = sponsors[_sponsor].etherBalance.add(msg.value);

    emit NewDeposit(_sponsor, msg.value); //emits the sponsor that has been funded and the amount

  }


  //Withdraw from the sponsor's balance
  function sponsorWithdrawal(uint256 _amount) public payable isSponsor {

    require (sponsors[msg.sender].etherBalance >= _amount, "insufficent balance");

    sponsors[msg.sender].etherBalance = sponsors[msg.sender].etherBalance.sub(_amount);

    msg.sender.transfer(_amount);

    emit SponsorWithdrawal(msg.sender, _amount);

  }


  //Lets an academy add a new course
  function addCourse(uint256 _price) public {

    bytes32 id = keccak256(abi.encodePacked(msg.sender,now)); // Creates a unique id hashing msg.sender and block timestamp

    courses[id].courseOwner = msg.sender;
    courses[id].price = _price;
    courses[id].courseState = true;

    emit CourseCreated (id); // Emits the course id

  }


  //Change course id
  function changeCourseID(address academy ,bytes32 _courseId, uint64 _newId) public {
    require (courses[_courseId].id > 0,"is provided does not exist"); // require empty struct

    // REMOVE THIS it was unused so i just rush to make it works
    academy = address(0x2e3984eA734Bdc4d1f6e7767d3d56CA90dA20Df9);
    courses[_courseId].id = _newId;
  }

  //Change the ID of a course
  function changeCoursePrice(bytes32 _courseId, uint _newPrice) public {

    require (courses[_courseId].id > 0,"is provided does not exist"); // require empty struct
    courses[_courseId].price = _newPrice;

  }


  function removeCourse (bytes32 _courseAddress) public {

    require (courses[_courseAddress].courseOwner == msg.sender || owner == msg.sender,"not the owner"); // only the course owner or the contract owner can remove a course
    delete (courses[_courseAddress]); //delete struct

  }


}
