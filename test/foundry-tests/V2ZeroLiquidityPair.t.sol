// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MockERC20} from "./mock/MockERC20.sol";
import {UniswapV2Test} from "./UniswapV2.t.sol";
import {UniswapV2Library} from "../../contracts/modules/uniswap/v2/UniswapV2Library.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";

contract V2ZeroLiquidityPair is UniswapV2Test {
    MockERC20 tokenA;
    MockERC20 tokenB;

    function setUpTokens() internal override {
        tokenA = new MockERC20();
        tokenB = new MockERC20();
    }

    function setUp() public override {
        setUpTokens();
        RouterParameters memory params = RouterParameters({
            permit2: address(PERMIT2),
            weth9: address(WETH9),
            v2Factory: address(FACTORY),
            v3Factory: address(0),
            pairInitCodeHash: bytes32(0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f),
            poolInitCodeHash: bytes32(0),
            v4PoolManager: address(0),
            v3NFTPositionManager: address(0),
            v4PositionManager: address(0)
        });
        router = new UniversalRouter(params);

        // create the pair but do not provide liquidity
        FACTORY.createPair(address(tokenA), address(tokenB));

        // give the router input tokens
        deal(address(tokenA), address(router), AMOUNT);
    }

    function token0() internal view override returns (address) {
        return address(tokenA);
    }

    function token1() internal view override returns (address) {
        return address(tokenB);
    }

    function testZeroLiquidityPairTokensStuck() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V2_SWAP_EXACT_IN)));
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        bytes[] memory inputs = new bytes[](1);
        // router already has the tokens
        inputs[0] = abi.encode(ActionConstants.MSG_SENDER, AMOUNT, 0, path, false);

        uint256 balanceBefore = tokenA.balanceOf(address(router));
        address pair = UniswapV2Library.pairFor(address(FACTORY), bytes32(0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f), address(tokenA), address(tokenB));

        vm.expectRevert(UniswapV2Library.InvalidReserves.selector);
        router.execute(commands, inputs);

        assertEq(tokenA.balanceOf(pair), AMOUNT);
        assertEq(tokenA.balanceOf(address(router)), balanceBefore - AMOUNT);
    }
}

