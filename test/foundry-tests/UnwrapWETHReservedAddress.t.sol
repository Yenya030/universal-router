// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {ActionConstants} from '@uniswap/v4-periphery/src/libraries/ActionConstants.sol';
import {WETH} from 'lib/permit2/lib/solmate/src/tokens/WETH.sol';

contract UnwrapWETHReservedAddressTest is Test {
    UniversalRouter router;
    WETH weth;

    function setUp() public {
        weth = new WETH();
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(weth),
            v2Factory: address(0),
            v3Factory: address(0),
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: bytes32(0),
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);
        weth.deposit{value: 1 ether}();
        weth.transfer(address(router), 1 ether);
    }

    function testUnwrapWETHToReservedAddress() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.UNWRAP_WETH)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(2), 0);

        router.execute(commands, inputs);

        assertEq(address(router).balance, 1 ether, 'ETH stays in router');
        assertEq(weth.balanceOf(address(router)), 0, 'WETH burned');
    }
}
