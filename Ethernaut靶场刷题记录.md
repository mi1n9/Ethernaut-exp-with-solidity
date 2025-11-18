---
title: Ethernaut靶场刷题记录
date: 2025-04-01 23:18:25
tags: blockchain

---

持续更新ing

<!-- more -->

# 1，Hello Ethernaut

跟着提示输入就行，这一节只是简单教你如何在Ethernaut网站使用控制台和合约进行交互，包括查看合约详情信息、调用合约内方法等。

```javascript
contract.info()
// "You will find what you need in info1()."
contract.info1()
// "Try info2(), but with "hello" as a parameter."
contract.info2('hello')
// "The property infoNum holds the number of the next info method to call."
contract.infoNum()
// 42
contract.info42()
// "theMethodName is the name of the next method."
contract.theMethodName()
// "The method name is method7123949."
contract.method7123949()
// "If you know the password, submit it to authenticate()."
contract.password()
// "ethernaut0"
contract.authenticate('ethernaut0')
```

# 2，Fallback

先来看给出的合约代码

```java
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
```

题目是fallback，那么啥是fallback呢，就是当其他合约调用该合约切该合约不存在相应函数就会触发fallback，fallback功能由合约所有者自定义。

简单分析合约：

令合约创建者为owner，其贡献值为1000eth；

contribute方法要求发送的ether不超过0.001eth，然后记录发送者贡献；

onlyOwner修改器要求交易发送者必须为owner；

withdraw方法由onlyOwner修改器控制，内容为取走合约内所有ether；

最下面的receive是如果交易发送者贡献大于0且向合约发送的eth大于0，则owner易主，变为交易发送者

这里涉及到更改owner的地方只有2处，首先是contribute函数，可以观察到他的条件很难触发，要我们的eth大于合约所有者的eth，但是合约所有者的eth在最开始就有1000，所以这是很难做到的。

再来看下面这个receive函数，有人向合约发送一些以太坊而没有在交易的 “数据”字段中指定任何东西时，receive 就会被 自动调用。那么receive就是接收到外部转账的时候会调用这个方法并执行里面的内容。那么思路已经很清晰了。首先调用contribute函数传一个小于0.001eth，这样发送者就会存在贡献，然后从外部向合约发送eth触发receive函数，使我们自己变为owner，在withdraw提取所有eth即可。这里提供两种解题方法。

## 1,f12直接交互

交互代码如下

```javascript
contract.contribute({value: toWei('0.0009', 'ether')})
contract.sendTransaction({from: player, to: instance, value: toWei('0.00001', 'ether')})
contract.withdraw()

```

就像上面讲的那样。第一步首先用小于0.001eth向合约捐献，调用contribute()函数，使我们拥有贡献值，然后从外部直接向合约发送1wei，触发recvie函数，即可成为owner。最后调用withdraw即可

## 2,solidity代码交互

刚开始学solidity，刚好多用用熟悉一下。

首先把代码全复制粘贴到remix.ide里，AT address