// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import {UniversalRouter} from '../../contracts/UniversalRouter.sol';
import {RouterParameters} from '../../contracts/types/RouterParameters.sol';
import {Commands} from '../../contracts/libraries/Commands.sol';
import {ActionConstants} from '@uniswap/v4-periphery/src/libraries/ActionConstants.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';

contract InvalidV3PathTest is Test {
    UniversalRouter router;
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(WETH),
            v2Factory: address(0),
            v3Factory: address(1),
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: bytes32(0),
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);
    }

    function testInvalidPathLengthReverts() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN)));
        bytes[] memory inputs = new bytes[](1);
        // supply an empty bytes path
        bytes memory invalidPath = hex"";
        inputs[0] = abi.encode(ActionConstants.MSG_SENDER, 1 ether, 0, invalidPath, true);

        vm.expectRevert();
        router.execute(commands, inputs);
    }
}
