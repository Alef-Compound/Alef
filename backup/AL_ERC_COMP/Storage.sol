pragma solidity 0.6.0;

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
}

import "./IERC20.sol";
import './ComptrollerInterface.sol';
import './CTokenInterface.sol';
import "../Safe/Ownable.sol";
import "../Safe/SafeMath.sol";
import "../Safe/Pausable.sol";

contract Storage is Ownable, Pausable {


  address internal daiContractAddress; // Contains Dai SmartContract address || 0x6B175474E89094C44Da98b954EedeAC495271d0F ||
  address internal cDaiContractAddress; // Contains cDai SmartContract address || 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 ||
  address internal cEthContractAddress; // Contains eEth SmartContract address || 0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5 ||


  uint256 public contractEtherBalance; // Total amount of Ether in contract
  uint256 public contractDaiBalance; // Total amount of Dai in contract
  uint256 public contractCethBalance; // Total amount of cEther in contract
  uint256 public contractCdaiBalance; // Total amount of cDai in contract


  // require sponsor
  modifier isSponsor() {
    require (sponsors[msg.sender].status == true);
    _;
  }


  //@Dev-> multiple balances hold different tokens - be mindiful when coding
  //Status: if sponsor is active == true

  struct Sponsor {
    // true if sponsor
    bool status;
    // sponsor ether balance
    uint256 etherBalance;
    // sponsor cEth balance
    uint256 cEtherBalance;
    // sponsor Dai balance
    uint256 daiBalance;
    // sponsor cDai balance
    uint256 cDaiBalance;
    // goal is the amount sponsor needs to reach to pay the selected course
    uint256 goal;
    // the id of the course the sponsor wants to pay
    bytes32 courseId;
  }


  //@Dev-> student balance mult not change until a funding is completed
  //Status: if student is active == true

  struct Student {
    bool status;
    uint256 balance;
  }


  // address owner the one who registers the course
  // unique id bytes32
  // Status: if course is active == true

  struct Course {
    //course owner
    address courseOwner;
    //Price of the course
    uint256 price;
    // true if active
    bool courseState;

  }

  // mapping sponsors => address
  mapping (address => Sponsor) internal sponsors;

  // mapping students => address
  mapping (address => Student) internal students;

  // mapping courses => bytes32
  mapping (bytes32 => Course) internal courses;


  // Declare events for actions we may want to watch
  event SponsorAction(address indexed sponsor, bytes32 action);
  event NewDeposit(address indexed sponsor, uint256 amt);
  event SponsorWithdrawal(address indexed sponsor, uint256 amt);
  event OwnerChanged(address indexed owner, address indexed newOwner);
  event academyWithdrawal(address indexed academy, uint256 amt);
  event CourseCreated(address indexed academy, uint256 indexed course, uint256 indexed price);
  event CourseRemoved(address indexed academy, uint256 indexed course, bytes32 action);
  event ScholarshipCreated(uint256 indexed studentID, address indexed academy, uint256 indexed course);
  event AcademyAction(address indexed academy, bytes32 action);
  event CourseCreated (bytes32 courseId);


  // GETTER METHODS - SPONSOR STRUCT

  function getSponsorEtherBalance (address _address) public view returns (uint256) {
    //@-> return Ether balance in sponsor struct
    return sponsors[_address].etherBalance;
  }

  function getSponsorCetherBalance (address _address) public view returns (uint256) {
    //@-> return cEther balance in sponsor struct
    return sponsors[_address].cEtherBalance;
  }

  function getSponsorDaiBalance (address _address) public view returns (uint256) {
    //@-> return Dai balance in sponsor struct
    return sponsors[_address].daiBalance;
  }

  function getSponsorCdaiBalance(address _address) public view returns (uint256) {
    //@-> return cDai balance in sponsor struct
    return sponsors[_address].cDaiBalance;
  }

  function getSponsorStatus (address _address) public view returns (bool) {
    //@-> return status in sponsor struct
    return sponsors[_address].status;
  }



  // GETTER METHODS - STUDENT STRUCT

  function getStudentBalance(address _academy) public view returns (uint256) {
    //@-> return Ether balance in academy struct
    return students[_academy].balance;
  }

  function getStudentStatus(address _academy) public view returns (bool) {
    //@-> return status in academy struct
    return students[_academy].status;
  }




  // GETTER METHODS - COURSE STRUCT

  function getCourseOwner (bytes32 _courseId) public view returns (address) {
    //@-> return owner in course struct
    return courses[_courseId].courseOwner;
  }

  function getCoursePrice (bytes32 _courseId) public view returns (uint256) {
    //@-> return owner in course struct
    return courses[_courseId].price;
  }

  function getCourseState (bytes32 _courseId) public view returns (bool) {
    //@-> return owner in course struct
    return courses[_courseId].courseState;
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
