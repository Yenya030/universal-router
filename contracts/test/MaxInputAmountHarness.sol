// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MaxInputAmount} from '../libraries/MaxInputAmount.sol';

contract MaxInputAmountHarness {
    using MaxInputAmount for uint256;

    function set(uint256 value) external {
        MaxInputAmount.set(value);
    }

    function setAndRevert(uint256 value) external {
        MaxInputAmount.set(value);
        revert('revert for test');
    }

    function get() external view returns (uint256) {
        return MaxInputAmount.get();
    }
}
