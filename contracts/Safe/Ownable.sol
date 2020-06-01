pragma solidity ^0.6.0;

contract Ownable{
    address payable owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "Function restricted to the owner");
        _;
    }

    function modifyOwner (address payable _newOwner) onlyOwner public returns (bool){
      owner = _newOwner;
      return true;
    }
}
