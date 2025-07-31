// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {MaxInputAmountHarness} from '../../contracts/test/MaxInputAmountHarness.sol';

contract MaxInputAmountResetHarnessTest is Test {
    MaxInputAmountHarness harness;

    function setUp() public {
        harness = new MaxInputAmountHarness();
    }

    function testResetAfterRevert() public {
        vm.expectRevert(bytes('revert for test'));
        harness.setAndRevert(123);
        assertEq(harness.get(), 0);
    }
}
