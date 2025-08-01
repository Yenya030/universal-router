// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {IUniversalRouter} from "../../contracts/interfaces/IUniversalRouter.sol";

contract DeadlineBypassTest is Test {
    UniversalRouter router;

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

    function testDeadlineEnforced() public {
        bytes memory commands = hex"";
        bytes[] memory inputs = new bytes[](0);
        vm.warp(1000);
        vm.expectRevert(IUniversalRouter.TransactionDeadlinePassed.selector);
        router.execute(commands, inputs, 999);
    }

    function testExecuteWithoutDeadlineSucceeds() public {
        bytes memory commands = hex"";
        bytes[] memory inputs = new bytes[](0);
        vm.warp(1000);
        router.execute(commands, inputs);
    }
}
