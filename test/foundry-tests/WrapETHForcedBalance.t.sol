// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {ActionConstants} from '@uniswap/v4-periphery/src/libraries/ActionConstants.sol';
import {WETH} from 'lib/permit2/lib/solmate/src/tokens/WETH.sol';
import {ForceETH} from '../../contracts/test/ForceETH.sol';

contract WrapETHForcedBalanceTest is Test {
    UniversalRouter router;
    WETH weth;
    ForceETH force;

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
        force = new ForceETH{value: 1 ether}();
    }

    function testWrapETHUsesEntireBalance() public {
        // force ETH into the router
        force.destroy(payable(address(router)));
        assertEq(address(router).balance, 1 ether);

        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.WRAP_ETH)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(this), ActionConstants.CONTRACT_BALANCE);

        router.execute(commands, inputs);

        assertEq(weth.balanceOf(address(this)), 1 ether);
        assertEq(address(router).balance, 0);
    }
}
