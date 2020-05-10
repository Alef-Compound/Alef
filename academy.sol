pragma solidity ^0.5.0;

contract Alef {
    
     address public owner;
     
     struct Academy {
    // If the sponser can administer their account.
    bool status;
    // A record of the amount held for the sponsor.
    uint balance;
     }
     
     
  
  // A mapping with account address as key and sponser data sturcture as value.
  mapping(address => Academy) public academies;
  // A mapping to behave as an index of addreesses
  mapping (int8 => address) public academyIndex;//  
  // Keep note of total number of participants in the system so we can iterate over index.
  int8 public academiesIndexSize;
  

   // Declare events for actions we may want to watch
  event AcademyAction(address indexed academy, bytes32 action);
  event NewDeposit(address indexed sponsor, uint amt);
  event OwnerChanged(address indexed owner, address indexed newOwner);


  
  // Constructor
    constructor() public {
    // Set the address of the contract deployer to be owner.
    owner = msg.sender;
  }
  
  // Check if current account calling methods is the owner.
  modifier isOwner() {
    
      require (msg.sender == owner);
    _;
  }
  
  // Check if current account calling methods is a valid sponsor of the contract.
  modifier isAcademy() {
   require (academies[msg.sender].status == true);
    _;
  }
  
  // Add a new sponsor to the contract.
  function addAcademy(address _academy) isOwner public returns (bool) {

    academies[_academy].status = true;
    academyIndex[academiesIndexSize] = _academy;
    academiesIndexSize++;

    emit AcademyAction(_academy, 'added');
  }
  
  // Disallow an account address from acting on contract.
  function disableAcademy(address _academy) isOwner public returns (bool) {
    require (_academy != owner) ; // Don't lock out the main account
    academies[_academy].status = false;
    emit AcademyAction(_academy, 'disabled');
  }

  // Allow an account address from acting on contract.
  function enableAcademy(address _address) isOwner public returns (bool) {
    academies[_address].status = true;
    emit AcademyAction(_address, 'enabled');
  }


  
  //Get the balance of a sponsor
  function getBalance(address _address) isAcademy public view returns (uint) {
  
    return academies[_address].balance;
  }  
  
  //Get the status of a sponsor
    function getStatus(address _address) public view returns(bool)  {
    return academies[_address].status;
  }
  

 struct Course {
     
    uint price;
    
 }
 
 mapping (address => Course) public courses;
   mapping (int8 => address) public courseIndex;//  
int8 public coursesIndexSize;
 
  // mapping(uint => uint) public coursesIndex;


   function addCourse( uint _price) isAcademy public {
      
       address creator = msg.sender;
     Course memory newCourse;
     newCourse.price = _price;
      courses[creator]=newCourse;
       courseIndex[coursesIndexSize] = creator;
    coursesIndexSize++;
     
   }
   
   function getCourse() public view returns (uint _price) {
       address creator = msg.sender;
       return (courses[creator].price);
   }


  // Change ownership of the contract.
  function transferOwner(address payable newOwner)  isOwner public returns (bool)  { //view and event cannot be together
    require (!academies[newOwner].status != true);
    emit OwnerChanged(owner, newOwner);
    owner = newOwner;
  }
  
  
}

