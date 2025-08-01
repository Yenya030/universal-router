// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {Constants} from "../../contracts/libraries/Constants.sol";

contract EmptyCommandsTest is Test {
    UniversalRouter router;

    receive() external payable {}

    function setUp() public {
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(0),
            v2Factory: address(0),
            v3Factory: address(0),
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: bytes32(0),
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);
    }

    function testEmptyCommandsLeavesEthBalance() public {
        router.execute{value: 1 ether}(hex"", new bytes[](0));
        assertEq(address(router).balance, 1 ether);
    }

    function testAnyoneCanSweepRemainingEth() public {
        router.execute{value: 1 ether}(hex"", new bytes[](0));
        uint256 start = address(this).balance;
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.SWEEP)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(Constants.ETH, address(this), 0);
        router.execute(commands, inputs);
        assertEq(address(this).balance - start, 1 ether);
        assertEq(address(router).balance, 0);
    }
}
