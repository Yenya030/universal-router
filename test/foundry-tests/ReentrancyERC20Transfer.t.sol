// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {ReenteringERC20} from '../../contracts/test/ReenteringERC20.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {Constants} from '../../contracts/libraries/Constants.sol';
import {ActionConstants} from '@uniswap/v4-periphery/src/libraries/ActionConstants.sol';

interface IRouterNoDeadline {
    function execute(bytes calldata commands, bytes[] calldata inputs) external payable;
}

contract ReentrancyERC20TransferTest is Test {
    UniversalRouter router;
    ReenteringERC20 token;

    function setUp() public {
        token = new ReenteringERC20();
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
        token.mint(address(router), 1 ether);
    }

    function testReentrancyOnTransferBlocked() public {
        bytes memory reenterCommands = abi.encodePacked(bytes1(uint8(Commands.SWEEP)));
        bytes[] memory reenterInputs = new bytes[](1);
        reenterInputs[0] = abi.encode(Constants.ETH, address(this), 0);
        token.setParameters(
            address(router),
            abi.encodeCall(IRouterNoDeadline.execute, (reenterCommands, reenterInputs))
        );

        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.TRANSFER)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(token), address(this), 1 ether);

        vm.expectRevert(bytes("TRANSFER_FAILED"));
        router.execute(commands, inputs);
    }
}
