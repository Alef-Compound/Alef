pragma solidity ^0.5.0;

contract Alef {
    
     address public owner;
     
  struct Sponsor {
    // If the sponser can administer their account.
    bool status;
    // A record of the amount held for the sponsor.
    uint balance;
  }
  // A mapping with account address as key and sponser data sturcture as value.
  mapping(address => Sponsor) public sponsors;
  // A mapping to behave as an index of addreesses
  mapping (int8 => address) public sponsorIndex;//  
  // Keep note of total number of participants in the system so we can iterate over index.
  int8 public sponsorsIndexSize;
  
   // Declare events for actions we may want to watch
  event SponsorAction(address indexed sponsor, bytes32 action);
  event NewDeposit(address indexed sponsor, uint amt);
  event SponsorWithdrawal(address indexed sponsor, uint amt);
  event OwnerChanged(address indexed owner, address indexed newOwner);
  event AcademyWithdrawal(address indexed academy, uint amt);
  event CourseCreated(address indexed academy, uint indexed course, uint indexed price);
  event CourseRemoved(address indexed academy, uint indexed course, bytes32 action);


  
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
  modifier isSponsor() {
    require (sponsors[msg.sender].status == true);
    _;
  }
  
  // Add a new sponsor to the contract.
  function addSponsor(address _sponsor) isOwner public returns (bool) {

    sponsors[_sponsor].status = true;
    sponsorIndex[sponsorsIndexSize] = _sponsor;
    sponsorsIndexSize++;

    emit SponsorAction(_sponsor, 'added');
  }
  
  // Disallow an account address from acting on contract.
  function disableSponsor(address _sponsor) isOwner public returns (bool) {
    require (_sponsor != owner) ; // Don't lock out the main account
    sponsors[_sponsor].status = false;
    emit SponsorAction(_sponsor, 'disabled');
  }

  // Allow an account address from acting on contract.
  function enableSponsor(address _address) isOwner public returns (bool) {
    sponsors[_address].status = true;
    emit SponsorAction(_address, 'enabled');
  }

// Function which will accept desposits.
   function deposit() isSponsor payable public {

  require (msg.value != 0) ;
  
    int8 i;
    // Update account balances for all sponsors.
    for (i=0;i<sponsorsIndexSize;i++) {
       if (sponsors[sponsorIndex[i]].status == true) {
         
         sponsors[sponsorIndex[i]].balance += msg.value;
       }
}
    emit NewDeposit(msg.sender, msg.value);
  }

  //Withdraw from the sponsor's balance
    function sponsorWithdrawal(uint amount) payable isSponsor public {
    require (sponsors[msg.sender].status == true || amount > sponsors[msg.sender].balance);
    require (msg.sender.send(amount));
    emit SponsorWithdrawal(msg.sender, amount);

        sponsors[msg.sender].balance -= amount;
  }
  function getSponsorBalance(address _address) isSponsor  public view returns (uint) {
  
    return sponsors[_address].balance;
  }  
  
    function getSponsorStatus(address _address) public view returns(bool)  {
    return sponsors[_address].status;
  }

   struct Academy {
    // If the academy can administer their account.
    bool status;
    // A record of the amount held for the academy.
    uint balance;
     }
     
     
  
  // A mapping with account address as key and academy data sturcture as value.
  mapping(address => Academy) public academies;
  // A mapping to behave as an index of addreesses
  mapping (int8 => address) public academyIndex;//  
  // Keep note of total number of academies in the system so we can iterate over index.
  int8 public academiesIndexSize;
  

  event AcademyAction(address indexed academy, bytes32 action);
 


  
  // Check if current account calling methods is a valid academy of the contract.
  modifier isAcademy() {
    require (academies[msg.sender].status == true);
    _;
  }
  
  // Add a new academy to the contract.
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


  
  //Get the balance of an academy
  function getBalance(address _address) isAcademy public view returns (uint) {
  
    return academies[_address].balance;
  }  
  
  //Get the status of an academy
    function getStatus(address _address) public view returns(bool)  {
    return academies[_address].status;
  }
  

 struct Course {
     //Academy's public key
    address academy;
    //Price of the course
    uint price;
    //The course's ID
    uint courseID;
 }
 
  // courses (Academies offering online courses)
  Course[] public courses;

   //Map (address, ID) to index into courses
   mapping (address => mapping(uint => uint)) public courseIndex;
   
 

 //Lets an academy add a new course
   function addCourse(uint _courseID, uint _price) isAcademy public {
       
   uint idx = courseIndex[msg.sender][_courseID];
   idx = courses.length;

   courseIndex[msg.sender][_courseID]= idx;

    
    courses.push(Course({
      academy: msg.sender,
      courseID: _courseID,
      price: _price
      }));
          emit CourseCreated(courses[idx].academy, courses[idx].courseID, courses[idx].price);

   }
   
      //Change the ID of a course
   function changeCourseID(address academy ,uint _courseID, uint _newID) isAcademy public {
     uint idx = courseIndex[academy][_courseID];
     courses[idx].courseID = _newID;
   }
   
    //Change the ID of a course
    function changeCoursePrice(address academy ,uint _courseID, uint _newPrice) isAcademy public {
     uint idx = courseIndex[academy][_courseID];
     courses[idx].price = _newPrice;
   }
   
   //Gets the price of a listed course by the ID of the couse and its academy's address
  function getCourseByAcademyAndID( address academy, uint _courseID) external view returns(uint price) {
         uint idx = courseIndex[academy][_courseID];
         require(courses.length > idx);
         require(courses[idx].courseID == _courseID);
         return (courses[idx].price);
  }
  
  //Removes a course listed by an academy
  function removeCourseByID(uint _courseID) isAcademy public {
       
          uint idx = courseIndex[msg.sender][_courseID];
       for (uint i = idx; i<courses.length-1; i++){
            courses[i] = courses[i+1];
        }
        delete courses[courses.length-1];
        courses.pop();
        emit CourseRemoved(courses[idx].academy, courses[idx].courseID, 'Removed');


       
    }
    
    //Withdraw from the academy's balance
  function academywithdrawal(uint amount) payable isSponsor public {
      
        require (sponsors[msg.sender].status == true || amount > sponsors[msg.sender].balance);
        require (msg.sender.send(amount));
        emit AcademyWithdrawal(msg.sender, amount);
        sponsors[msg.sender].balance -= amount;
  }
  

  // Change ownership of the contract.
  function transferOwner(address payable newOwner)  isOwner public returns (bool)  {
         require (!sponsors[newOwner].status != true);
         emit OwnerChanged(owner, newOwner);
         owner = newOwner;
  }
  
}
