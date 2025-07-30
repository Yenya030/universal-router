// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Payments} from '../modules/Payments.sol';
import {PaymentsImmutables, PaymentsParameters} from '../modules/PaymentsImmutables.sol';

contract PaymentsHarness is Payments {
    constructor(address weth) PaymentsImmutables(PaymentsParameters(address(0), weth)) {}

    function harnessPayPortion(address token, address recipient, uint256 bips) external payable {
        payPortion(token, recipient, bips);
    }
}
