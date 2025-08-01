// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MockPermit2} from "../../contracts/test/MockPermit2.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {MockERC20} from "./mock/MockERC20.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";

contract Permit2ReservedAddressTest is Test {
    UniversalRouter router;
    MockPermit2 permit2;
    MockERC20 token;
    uint256 constant AMOUNT = 1 ether;

    function setUp() public {
        permit2 = new MockPermit2();
        RouterParameters memory params = RouterParameters({
            permit2: address(permit2),
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
        token.mint(address(this), AMOUNT);
        token.approve(address(permit2), AMOUNT);
        permit2.approve(address(token), address(router), type(uint160).max, type(uint48).max);
    }

    function testPermit2TransferToReservedAddress() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.PERMIT2_TRANSFER_FROM)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(token), ActionConstants.ADDRESS_THIS, AMOUNT);

        router.execute(commands, inputs);

        assertEq(token.balanceOf(address(router)), AMOUNT, "router keeps tokens");
        assertEq(token.balanceOf(ActionConstants.ADDRESS_THIS), 0, "target did not receive tokens");
    }
}
