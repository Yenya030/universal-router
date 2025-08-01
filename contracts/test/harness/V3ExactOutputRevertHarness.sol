// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {V3SwapRouter} from "../../modules/uniswap/v3/V3SwapRouter.sol";
import {Permit2Payments} from "../../modules/Permit2Payments.sol";
import {PaymentsImmutables, PaymentsParameters} from "../../modules/PaymentsImmutables.sol";
import {UniswapImmutables, UniswapParameters} from "../../modules/uniswap/UniswapImmutables.sol";
import {MaxInputAmount} from "../../libraries/MaxInputAmount.sol";

contract V3ExactOutputRevertHarness is V3SwapRouter {
    constructor()
        UniswapImmutables(UniswapParameters(address(0), address(0), bytes32(0), bytes32(0)))
        PaymentsImmutables(PaymentsParameters(address(0), address(0)))
    {}

    function callExactOutRevert(bytes calldata path) external {
        v3SwapExactOutput(address(this), 1 ether, 1 ether, path, address(this));
    }

    function getMaxInput() external view returns (uint256) {
        return MaxInputAmount.get();
    }
}
