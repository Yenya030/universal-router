// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract MockV4PositionManager {
    uint256 public lastValue;
    bytes public lastUnlockData;
    uint256 public lastDeadline;

    function modifyLiquidities(bytes calldata unlockData, uint256 deadline) external payable {
        lastValue = msg.value;
        lastUnlockData = unlockData;
        lastDeadline = deadline;
    }
}
