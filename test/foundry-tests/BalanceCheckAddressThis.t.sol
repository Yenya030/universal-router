// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {MockERC20} from "./mock/MockERC20.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";
import {Dispatcher} from "../../contracts/base/Dispatcher.sol";
import {IUniversalRouter} from "../../contracts/interfaces/IUniversalRouter.sol";

contract BalanceCheckAddressThisTest is Test {
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

    function testBalanceCheckAddressThisReverts() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.BALANCE_CHECK_ERC20)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(ActionConstants.ADDRESS_THIS, address(token), token.balanceOf(address(router)));

        vm.expectRevert(
            abi.encodeWithSelector(
                IUniversalRouter.ExecutionFailed.selector,
                uint256(0),
                abi.encodePacked(Dispatcher.BalanceTooLow.selector)
            )
        );
        router.execute(commands, inputs);
    }
}
