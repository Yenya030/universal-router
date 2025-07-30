// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {ReenteringWETH} from '../../contracts/test/ReenteringWETH.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {Constants} from '../../contracts/libraries/Constants.sol';
import {ActionConstants} from '@uniswap/v4-periphery/src/libraries/ActionConstants.sol';

interface IRouterNoDeadline {
    function execute(bytes calldata commands, bytes[] calldata inputs) external payable;
}

contract ReentrancyTest is Test {
    UniversalRouter router;
    ReenteringWETH weth;

    function setUp() public {
        weth = new ReenteringWETH();
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
    }

    function testReentrancyBlocked() public {
        bytes memory reenterCommands = abi.encodePacked(bytes1(uint8(Commands.SWEEP)));
        bytes[] memory reenterInputs = new bytes[](1);
        reenterInputs[0] = abi.encode(Constants.ETH, address(this), 0);

        weth.setParameters(address(router), abi.encodeCall(IRouterNoDeadline.execute, (reenterCommands, reenterInputs)));

        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.WRAP_ETH)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(ActionConstants.ADDRESS_THIS, 1 ether);

        vm.expectRevert(ReenteringWETH.NotAllowedReenter.selector);
        router.execute{value: 1 ether}(commands, inputs);
    }
}
