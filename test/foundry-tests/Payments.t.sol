// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {PaymentsHarness} from '../../contracts/test/PaymentsHarness.sol';
import {MockERC20} from './mock/MockERC20.sol';
import {Constants} from '../../contracts/libraries/Constants.sol';
import {BipsLibrary} from '@uniswap/v4-periphery/src/libraries/BipsLibrary.sol';

contract PaymentsTest is Test {
    PaymentsHarness harness;
    MockERC20 token;

    function setUp() public {
        harness = new PaymentsHarness(address(0));
        token = new MockERC20();
        token.mint(address(harness), 100 ether);
        vm.deal(address(harness), 10 ether);
    }

    function testPayPortionInvalidBips() public {
        vm.expectRevert(BipsLibrary.InvalidBips.selector);
        harness.harnessPayPortion(Constants.ETH, address(1), 10001);
    }
}
