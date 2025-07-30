pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {MockERC20} from './mock/MockERC20.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';

contract AllowRevertTest is Test {
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
    }

    function test_PayPortionAllowRevert() public {
        token.mint(address(router), 1 ether);
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.PAY_PORTION) | uint8(Commands.FLAG_ALLOW_REVERT)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(address(token), address(1), 10001);
        vm.expectRevert();
        router.execute(commands, inputs);
    }
}
