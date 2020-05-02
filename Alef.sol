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
  function deposit() payable public {

  require (msg.value != 0) ;
    int8 i;
    // Update account balances for all sponsors.
    for (i=0;i<sponsorsIndexSize;i++) {
       if (sponsors[sponsorIndex[i]].status == true) {
         
         sponsors[sponsorIndex[i]].balance = msg.value;
       }
    }

    emit NewDeposit(msg.sender, msg.value);
  }
  
  function getBalance(address _address) isSponsor  public view returns (uint) {
  
    return sponsors[_address].balance;
  }  
  
    function getStatus(address _address) public view returns(bool)  {
    return sponsors[_address].status;
  }


  // Change ownership of the contract.
  function transferOwner(address payable newOwner)  isOwner public returns (bool)  { //view and event cannot be together
    require (!sponsors[newOwner].status != true);
    emit OwnerChanged(owner, newOwner);
    owner = newOwner;
  }
  
}
