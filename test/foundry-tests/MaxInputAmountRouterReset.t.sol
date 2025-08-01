// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {V3ExactOutputRevertHarness} from "../../contracts/test/harness/V3ExactOutputRevertHarness.sol";

contract MaxInputAmountRouterResetTest is Test {
    V3ExactOutputRevertHarness harness;

    function setUp() public {
        harness = new V3ExactOutputRevertHarness();
    }

    function testRevertClearsMaxInput() public {
        bytes memory path = abi.encodePacked(address(1), uint24(500), address(2));
        vm.expectRevert();
        harness.callExactOutRevert(path);
        assertEq(harness.getMaxInput(), 0);
    }
}
