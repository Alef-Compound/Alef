pragma solidity ^0.6.0;

//0x6B175474E89094C44Da98b954EedeAC495271d0F DAI
abstract contract Erc20 {
  function approve(address, uint)virtual external returns (bool);
  function transfer(address, uint)virtual external returns (bool);
  function balanceOf(address owner)virtual external view returns (uint256 balance);
}

//0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 cDai
abstract contract CErc20 {
  function approve(address, uint)virtual external returns (bool);
  function mint(uint)virtual external returns (uint);
  function balanceOfUnderlying(address account)virtual external returns (uint);
  function totalReserves()virtual external returns (uint);
}

//0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5
abstract contract CEth {
  function mint()virtual external payable;
  function balanceOfUnderlying(address account)virtual external returns (uint);
  function balanceOf(address owner)virtual external view returns (uint256 balance);
  function transfer(address dst, uint256 amount)virtual external returns (bool success);
  function transferFrom(address src, address dst, uint wad)virtual external returns (bool);
}
import "IERC20.sol";
import './ComptrollerInterface.sol';
import './CTokenInterface.sol';


contract MyContract {
  
  event displayCerc20Balance(uint256);
  event reserve(uint);  
  event isApproved(bool);
  
  function supplyEthToCompound(address payable _cEtherContract)
  public payable returns (bool)
  {
    CEth(_cEtherContract).mint.value(msg.value).gas(250000)();
    return true;
  }

  function supplyErc20ToCompound(
    address _erc20Contract,
    address _cErc20Contract,
    uint256 _numTokensToSupply
  ) public {
    // Create a reference to the underlying asset contract, like DAI.
    IERC20 underlying = IERC20(_erc20Contract);

    // Approve transfer on the ERC20 contract
    bool daiApprovalResult = underlying.approve(address(_cErc20Contract), _numTokensToSupply);
    require(daiApprovalResult, "Failed to approve cDAI contract to spend DAI");
    emit isApproved(daiApprovalResult);
  }

function mintCdai(address _cErc20Contract, uint256 _numTokensToSupply) public {
    CTokenInterface cDai = CTokenInterface(_cErc20Contract);
    assert(cDai.mint(_numTokensToSupply) == 0);
}
 

function getReserve(address _cErc20Contract) public returns(uint){
    // Create a reference to the corresponding cToken contract, like cDAI
    CErc20 cToken = CErc20(_cErc20Contract);
    uint reserves = cToken.totalReserves();
    emit reserve(reserves);
}

  function getCErc20Balance(address payable _cErc20Contract, address _myaddr) public {
    uint256 balance = CErc20(_cErc20Contract).balanceOfUnderlying(_myaddr);
    emit displayCerc20Balance(balance);
  }
  
  function getDaiBalance(address payable _erc20Contract, address _myaddr) public view returns(uint256){
      return Erc20(_erc20Contract).balanceOf(_myaddr);
  }
  
  function getCEthBalance(address payable _cEtherContract, address _myaddr) public view returns(uint256){
      return CEth(_cEtherContract).balanceOf(_myaddr);
  }
  
  function sendCEthToWallet(address payable _cEtherContract, address payable _dst, uint256 total) public returns(bool){
      return CEth(_cEtherContract).transferFrom(address(this), _dst ,total);
  }
  
  receive() external payable { }
}