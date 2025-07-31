// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract ForceETH {
    constructor() payable {}

    function destroy(address payable target) external {
        selfdestruct(target);
    }
}
