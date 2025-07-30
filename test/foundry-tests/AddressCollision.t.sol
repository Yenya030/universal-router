// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {MockERC20} from './mock/MockERC20.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';

contract AddressCollisionTest is Test {
    UniversalRouter router;
    MockERC20 token;
    address constant TARGET = address(2); // collides with ADDRESS_THIS constant
    uint256 constant AMOUNT = 1 ether;

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
        token.mint(address(router), AMOUNT);
    }

    function testTransferToAddressTwoGoesToRouter() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.TRANSFER)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(token), TARGET, AMOUNT);

        router.execute(commands, inputs);

        assertEq(token.balanceOf(address(router)), AMOUNT, 'router keeps tokens');
        assertEq(token.balanceOf(TARGET), 0, 'target did not receive tokens');
    }
}
