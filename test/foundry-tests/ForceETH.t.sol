// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {ForceETH} from '../../contracts/test/ForceETH.sol';

contract ForceETHTest is Test {
    UniversalRouter router;
    ForceETH force;

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
        force = new ForceETH{value: 1 ether}();
    }

    function testForceSendETH() public {
        assertEq(address(router).balance, 0);
        force.destroy(payable(address(router)));
        assertEq(address(router).balance, 1 ether);
    }
}
