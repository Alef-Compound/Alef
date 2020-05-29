pragma solidity 0.6.0;

import "./Storage.sol";
import "../Safe/SafeMath.sol";


contract Alef is Storage {


  using SafeMath for uint256;


  constructor (address _daiContractAddress, address _cDaiContractAddress, address _cEthContractAddress) public {
    // must set the 3 erc addresses
    daiContractAddress = _daiContractAddress;
    cDaiContractAddress = _cDaiContractAddress;
    cEthContractAddress = _cEthContractAddress;
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

    sponsors[msg.sender].balance = sponsors[msg.sender].balance.add(msg.value);

    emit NewDeposit(msg.sender, msg.value);
  }


  function fundSponsor (address _sponsor) public payable whenNotPaused {

    // anyone can fund a sponsor

    require (sponsors[_sponsor].status == true,"sponsor does not exist");

    sponsors[_sponsor].balance = sponsors[_sponsor].balance.add(msg.value);

    emit NewDeposit(_sponsor, msg.value); //emits the sponsor that has been funded and the amount

  }


  //Withdraw from the sponsor's balance
  function sponsorWithdrawal(uint256 _amount) public payable isSponsor {

    require (sponsors[msg.sender].balance >= _amount, "insufficent balance");

    sponsors[msg.sender].balance = sponsors[msg.sender].balance.sub(_amount);

    msg.sender.tranfer(_amount);

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
  function changeCourseID(address academy ,bytes32 _courseID, bytes32 _newID) public {

    require (courses[_courseID]._courseID == true,"is provided does not exist"); // require empty struct
    courses[_courseID].id = _newID;
  }


  //Change the ID of a course
  function changeCoursePrice(uint _courseID, uint _newPrice) public {

    require (courses[_courseID]._courseID == true,"is provided does not exist"); // require empty struct
    courses[_courseID].price = _newPrice;

  }


  function removeCourse (bytes32 _courseAddress) public {

    require (courses[_courseAddress].courseOwner == msg.sender || owner == msg.sender,"not the owner"); // only the course owner or the contract owner can remove a course
    delete (courses[_courseAddress]); //delete struct

  }


}
