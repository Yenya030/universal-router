// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract MockPermit2 is IAllowanceTransfer {
    function DOMAIN_SEPARATOR() external pure override returns (bytes32) {
        return bytes32(0);
    }
    function allowance(address, address, address) external view override returns (uint160, uint48, uint48) {
        return (type(uint160).max, type(uint48).max, 0);
    }

    function approve(address, address, uint160, uint48) external override {}

    function permit(address, PermitSingle memory, bytes calldata) external override {}

    function permit(address, PermitBatch memory, bytes calldata) external override {}

    function transferFrom(address from, address to, uint160 amount, address token) external override {
        ERC20(token).transferFrom(from, to, amount);
    }

    function transferFrom(AllowanceTransferDetails[] calldata details) external override {
        for (uint256 i = 0; i < details.length; i++) {
            ERC20(details[i].token).transferFrom(details[i].from, details[i].to, details[i].amount);
        }
    }

    function lockdown(TokenSpenderPair[] calldata) external override {}

    function invalidateNonces(address, address, uint48) external override {}
}
