// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {Permit2Payments} from "../../contracts/modules/Permit2Payments.sol";
import {PaymentsImmutables, PaymentsParameters} from "../../contracts/modules/PaymentsImmutables.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {MockERC20} from "./mock/MockERC20.sol";

contract Permit2PaymentsHarness is Permit2Payments {
    constructor(address permit2) PaymentsImmutables(PaymentsParameters({permit2: permit2, weth9: address(0)})) {}

    function callBatch(IAllowanceTransfer.AllowanceTransferDetails[] calldata details, address owner) external {
        permit2TransferFrom(details, owner);
    }
}

contract Permit2PaymentsTest is Test {
    Permit2PaymentsHarness harness;
    MockERC20 token;

    function setUp() public {
        harness = new Permit2PaymentsHarness(address(0));
        token = new MockERC20();
    }

    function testBatchFromMismatchReverts() public {
        IAllowanceTransfer.AllowanceTransferDetails[] memory details = new IAllowanceTransfer.AllowanceTransferDetails[](1);
        details[0] = IAllowanceTransfer.AllowanceTransferDetails({from: address(1), to: address(2), amount: 1, token: address(token)});
        vm.expectRevert(Permit2Payments.FromAddressIsNotOwner.selector);
        harness.callBatch(details, address(this));
    }
}
