// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {Constants} from '../../contracts/libraries/Constants.sol';
import {ReentrantReceiver} from './mock/ReentrantReceiver.sol';

contract ReentrancyTest is Test {
    UniversalRouter router;
    ReentrantReceiver receiver;

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
        receiver = new ReentrantReceiver(router);
    }

    function testReentrancyGuard() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.SWEEP)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(Constants.ETH, address(receiver), 0);

        router.execute{value: 1 ether}(commands, inputs);

        assertTrue(receiver.reentered());
    }
}
