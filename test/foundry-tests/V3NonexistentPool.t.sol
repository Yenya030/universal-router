// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {UniversalRouter} from "../../contracts/UniversalRouter.sol";
import {RouterParameters} from "../../contracts/types/RouterParameters.sol";
import {Commands} from "../../contracts/libraries/Commands.sol";
import {ActionConstants} from "@uniswap/v4-periphery/src/libraries/ActionConstants.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract V3NonexistentPoolTest is Test {
    address constant FROM = address(1234);
    uint256 constant AMOUNT = 1 ether;

    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
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

    function computePool() internal view returns (address pool) {
        address token0 = address(WETH) < address(DAI) ? address(WETH) : address(DAI);
        address token1 = address(WETH) < address(DAI) ? address(DAI) : address(WETH);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            FACTORY,
                            keccak256(abi.encode(token0, token1, uint24(123))),
                            INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }

    function testNonexistentPoolRevertsWithoutTransfer() public {
        bytes memory commands = abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN)));
        bytes[] memory inputs = new bytes[](1);
        bytes memory path = abi.encodePacked(address(WETH), uint24(123), address(DAI));
        inputs[0] = abi.encode(ActionConstants.MSG_SENDER, AMOUNT, 0, path, true);

        address pool = computePool();
        uint256 userBalanceBefore = WETH.balanceOf(FROM);
        uint256 routerBalanceBefore = WETH.balanceOf(address(router));

        vm.expectRevert();
        router.execute(commands, inputs);

        assertEq(WETH.balanceOf(FROM), userBalanceBefore, "user tokens moved");
        assertEq(WETH.balanceOf(address(router)), routerBalanceBefore, "router tokens moved");
        assertEq(WETH.balanceOf(pool), 0, "tokens sent to nonexistent pool");
    }
}
