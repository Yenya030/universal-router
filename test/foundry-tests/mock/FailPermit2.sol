// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract FailPermit2 {
    function transferFrom(address, address, uint160, address token) external {
        if (token == address(0)) revert("TRANSFER_FROM_FAILED");
    }
}
