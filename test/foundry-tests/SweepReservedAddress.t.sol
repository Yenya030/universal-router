// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {MockERC20} from "./mock/MockERC20.sol";

contract SweepReservedAddressTest is Test {
    UniversalRouter router;
    MockERC20 token;

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
        token = new MockERC20();
        token.mint(address(router), 1 ether);
    }

    function testSweepToReservedAddressSendsToCaller() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.SWEEP)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(token), address(1), 0);

        router.execute(commands, inputs);

        assertEq(token.balanceOf(address(1)), 0, "tokens not sent to reserved address");
        assertEq(token.balanceOf(address(this)), 1 ether, "caller received tokens");
        assertEq(token.balanceOf(address(router)), 0, "router balance cleared");
    }
}
