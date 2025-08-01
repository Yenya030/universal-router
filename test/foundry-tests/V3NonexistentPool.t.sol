// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {MockERC20} from "./mock/MockERC20.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";

contract V3NonexistentPoolTest is Test {
    UniversalRouter router;
    MockERC20 tokenA;
    MockERC20 tokenB;

    // random factory and init code hash
    address constant FACTORY = address(0x1111);
    bytes32 constant INIT_CODE_HASH = bytes32(uint256(0x2222));

    uint256 constant AMOUNT = 1 ether;

    function setUp() public {
        tokenA = new MockERC20();
        tokenB = new MockERC20();
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(0),
            v2Factory: address(0),
            v3Factory: FACTORY,
            pairInitCodeHash: bytes32(0),
            poolInitCodeHash: INIT_CODE_HASH,
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);
        tokenA.mint(address(router), AMOUNT);
    }

    function computePool(address token0, address token1, uint24 fee) internal pure returns (address pool) {
        if (token0 > token1) (token0, token1) = (token1, token0);
        pool = address(uint160(uint256(keccak256(abi.encodePacked(hex'ff', FACTORY, keccak256(abi.encode(token0, token1, fee)), INIT_CODE_HASH)))));
    }

    function testNonexistentPoolLosesFunds() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN)));
        bytes[] memory inputs = new bytes[](1);
        bytes memory path = abi.encodePacked(address(tokenA), uint24(3000), address(tokenB));
        // payerIsUser = false -> router pays using its balance
        inputs[0] = abi.encode(ActionConstants.ADDRESS_THIS, AMOUNT, 0, path, false);

        vm.expectRevert();
        router.execute(commands, inputs);

        address pool = computePool(address(tokenA), address(tokenB), 3000);
        assertEq(tokenA.balanceOf(pool), AMOUNT, "tokens transferred to computed pool address");
        assertEq(tokenA.balanceOf(address(router)), 0, "router balance should be empty");
    }
}
