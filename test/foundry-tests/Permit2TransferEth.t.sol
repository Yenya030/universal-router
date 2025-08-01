// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {Constants} from "../../contracts/libraries/Constants.sol";
import {FailPermit2} from "./mock/FailPermit2.sol";

contract Permit2TransferEthTest is Test {
    UniversalRouter router;
    FailPermit2 permit2;

    function setUp() public {
        permit2 = new FailPermit2();
        RouterParameters memory params = RouterParameters({
            permit2: address(permit2),
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
    }

    function testPermit2TransferEthTokenReverts() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.PERMIT2_TRANSFER_FROM)));
        bytes[] memory inputs = new bytes[](1);
        inputs[0] = abi.encode(Constants.ETH, address(this), uint160(1));

        vm.expectRevert("TRANSFER_FROM_FAILED");
        router.execute(commands, inputs);
    }
}
