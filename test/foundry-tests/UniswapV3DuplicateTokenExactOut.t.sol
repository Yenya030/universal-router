// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract UniswapV3DuplicateTokenExactOutTest is Test {
    address constant FROM = address(1234);
    uint256 constant AMOUNT = 1 ether;

    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    bytes32 constant INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    UniversalRouter router;

    function setUp() public {
        vm.createSelectFork(vm.envString("FORK_URL"), 20010000);

        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(WETH),
            v2Factory: address(0),
            v3Factory: FACTORY,
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: INIT_CODE_HASH,
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);

        deal(address(WETH), FROM, AMOUNT);
        vm.startPrank(FROM);
        WETH.approve(address(router), AMOUNT);
    }

    function testExactOutputDuplicateTokenPathReverts() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_OUT)));
        bytes[] memory inputs = new bytes[](1);

        bytes memory path = abi.encodePacked(address(WETH), uint24(3000), address(WETH));
        inputs[0] = abi.encode(ActionConstants.MSG_SENDER, AMOUNT, AMOUNT, path, true);

        vm.expectRevert();
        router.execute(commands, inputs);
    }
}
