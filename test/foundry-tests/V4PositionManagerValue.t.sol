// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ForceETH} from "../../contracts/test/ForceETH.sol";
import {MockV4PositionManager} from "./mock/MockV4PositionManager.sol";

contract V4PositionManagerValueTest is Test {
    UniversalRouter router;
    MockV4PositionManager manager;
    ForceETH force;

    function setUp() public {
        manager = new MockV4PositionManager();
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(0),
            v2Factory: address(0),
            v3Factory: address(0),
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: bytes32(0),
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(manager)
        });
        router = new UniversalRouter(params);
        force = new ForceETH{value: 1 ether}();
    }

    function testForwardsEntireBalance() public {
        // force 1 ether into the router
        force.destroy(payable(address(router)));
        assertEq(address(router).balance, 1 ether, "router should hold ETH");

        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V4_POSITION_MANAGER_CALL)));
        bytes[] memory inputs = new bytes[](1);
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(address(0), address(this));
        bytes memory unlockData = abi.encode(hex"14", params);
        inputs[0] = abi.encodeWithSelector(manager.modifyLiquidities.selector, unlockData, uint256(0));

        router.execute(commands, inputs);

        assertEq(manager.lastValue(), 1 ether, "manager received all ETH");
        assertEq(address(router).balance, 0, "router balance drained");
    }
}
