// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MockERC20} from "./mock/MockERC20.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";
import {WETH} from "lib/permit2/lib/solmate/src/tokens/WETH.sol";

contract UniswapV3NonexistentPoolTest is Test {
    MockERC20 tokenA;
    MockERC20 tokenB;
    WETH weth;
    UniversalRouter router;

    uint256 constant AMOUNT = 1 ether;
    address constant FACTORY = address(123456);
    bytes32 constant INIT_CODE_HASH = bytes32(0x0);

    function setUp() public {
        tokenA = new MockERC20();
        tokenB = new MockERC20();
        weth = new WETH();
        RouterParameters memory params = RouterParameters({
            permit2: address(0),
            weth9: address(weth),
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
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            FACTORY,
                            keccak256(abi.encode(token0, token1, fee)),
                            INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }

    function testNonexistentPoolLeavesTokensStuck() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN)));
        bytes[] memory inputs = new bytes[](1);
        bytes memory path = abi.encodePacked(address(tokenA), uint24(3000), address(tokenB));
        inputs[0] = abi.encode(ActionConstants.MSG_SENDER, AMOUNT, 0, path, false);

        address pool = computePool(address(tokenA), address(tokenB), 3000);
        uint256 balanceBefore = tokenA.balanceOf(address(router));

        vm.expectRevert();
        router.execute(commands, inputs);

        assertEq(tokenA.balanceOf(pool), 0);
        assertEq(tokenA.balanceOf(address(router)), balanceBefore);
    }
}

