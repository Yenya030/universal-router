# Tested Attack Vectors

This document lists the attack vectors that have been tested against the Universal Router code base. For each vector we describe the approach and whether a bug was discovered.

## Unauthorized ETH Transfers
  - **Vector**: Sending native ETH directly to the `receive()` function of `UniversalRouter` from an externally owned account.
  - **Result**: The transaction reverts with `InvalidEthSender`, confirming that the router rejects unauthorized ETH transfers. See `Receive.test.ts`.


## Reentrancy via Malicious WETH
  - **Vector**: Use a malicious WETH implementation that attempts to reenter the router during `deposit()`.
  - **Result**: The router rejects the reentrant call with `NotAllowedReenter`. This behavior is verified in `UniversalRouter.test.ts`.


## Invalid Command Types
  - **Vector**: Supply an invalid command byte when calling `execute`.
  - **Result**: The router reverts with `InvalidCommandType`, preventing execution of unknown commands. Tested in `UniversalRouter.test.ts`.


## Reentrancy via WETH deposit** – A malicious WETH token tries to reenter the router during a wrap.
  - Test location: `integration-tests/UniversalRouter.test.ts` lines 116-135.
  - Result: router reverts with `NotAllowedReenter` proving the lock prevents reentrancy.


## PAY_PORTION over 100%** – Attempting to pay a portion greater than 100% of the router balance.
  - Test location: `integration-tests/UniversalRouter.test.ts` lines 105-114.
  - Result: router reverts with `InvalidBips`.


## Sweep with insufficient balance** – Sweeping tokens or ETH when the contract does not hold enough funds.
  - Test location: `foundry-tests/UniversalRouter.t.sol`.
  - Result: router reverts with `InsufficientToken` or `InsufficientETH`.


## WrapETH insufficient balance** – Attempting to wrap more ETH than the router owns.
  - Test location: `foundry-tests/WrapETH.t.sol`.
  - Result: router reverts with `InsufficientETH`. A success path is also tested.


## Allow Revert Flag Handling
  - **Vector**: Use the `FLAG_ALLOW_REVERT` with a command that fails internally (e.g. `PAY_PORTION` with invalid bips).
  - **Result**: Failing internal commands still revert the entire transaction instead of being ignored. Verified with `AllowRevert.t.sol` test which expects a revert when the flag is set.
  - **Status**: **Bug discovered** – the allow revert flag does not work for certain internal commands.


##  Transient Storage Persistence
  - **Vector**: Reverting after calling functions that write to transient storage (e.g. `MaxInputAmount` or `Locker`) to see if the value persists and causes inconsistent state.
  - **Result**: Transient storage is cleared when the transaction reverts, so no state persists after failure.
  - **Status**: **Handled** – no persistent state was observed.


## Overflow in `BipsLibrary.calculatePortion`
  - **Vector**: Provide extremely large amounts to `calculatePortion` to test arithmetic overflow handling.
  - **Result**: Solidity 0.8 built‑in overflow checks correctly revert on overflow. No unexpected behaviour observed.
  - **Status**: **Handled** – library reverts as expected on overflow.

| Vector | Status | Notes |
| ------ | ------ | ----- |
| Reentrancy during `execute` via malicious ERC20 (wrap/unwrap) | Handled | Existing tests use a `ReenteringWETH` contract and the lock prevents reentry. |
| Invalid command bytes | Handled | `UniversalRouter` reverts with `InvalidCommandType` when unknown commands are provided. |
| Sweeping with excessively large portion | Handled | `Payments.payPortion` reverts with `InvalidBips` when over 100% is requested. |
| Use of `v3SwapExactOutput` with revert before clearing `MaxInputAmount` | Not tested* | Would verify that storage reset works correctly on revert but requires forked environment. |


## Reentrancy on ETH sweep
- **Vector**: Attempt reentrancy during an ETH sweep by sending ETH to a contract that immediately calls `UniversalRouter.execute` again.
- **Result**: Handled by the contract. The reentrant call reverted with `ContractLocked` proving the reentrancy guard works.
- **Test**: `ReentrancyTest.testReentrancyGuard`

## Locker transient storage
- **Vector**: Fuzz `Locker` library to ensure the lock can be set and cleared correctly.
- **Result**: Handled correctly. No inconsistencies found.
- **Test**: `LockerTest`

## MaxInputAmount storage
- **Vector**: Fuzz the `MaxInputAmount` library that uses transient storage to store a maximum input value.
- **Result**: Handled correctly. Values were stored and retrieved as expected.
- **Test**: `MaxInputAmountTest`

## Sweep functions
- **Vector**: Sweep ERC20 tokens and ETH to verify correct transfers and proper error handling when the minimum amount is not met.
- **Result**: Handled correctly. Sweeps succeeded when conditions were met and reverted otherwise.
- **Test**: `UniversalRouterTest`


## Transfer to reserved addresses
- **Vector:** Attempt to transfer ERC20 tokens to address `0x0000000000000000000000000000000000000001` via the router.
- **Finding:** Tokens are incorrectly sent to the caller instead of the intended address. This occurs because the router maps address `1` to `MSG_SENDER`.
- **Test:** `testTransferToReservedAddress` in `test/foundry-tests/UniversalRouter.t.sol` demonstrates the issue.


## Looping V2 swap path**: Crafted a path where the last hop returns to the first token (e.g. `[token0, token1, token0]`).
  - **Result**: Transaction reverts with `UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT` showing Universal Router does not gracefully handle looping paths.
  - **Bug?**: Yes. The router fails inside the pair contract instead of validating the path and reverting early.


## Looping V3 swap path
  - **Vector**: Provide a Uniswap v3 path that loops back to the input token (e.g. `[WETH, DAI, WETH]`) when calling `V3_SWAP_EXACT_IN`.
  - **Result**: The swap reverts from the pool (for example with `STF`) rather than the router validating the path.
  - **Bug?**: Yes. Similar to the V2 case, the router relies on the pool revert instead of rejecting looping paths.


## Looping V4 swap path
  - **Vector**: Craft a Uniswap v4 path where the final hop returns to the starting currency.
  - **Result**: The router allows the call to proceed and the transaction reverts from the pool manager rather than failing fast.
  - **Bug?**: Yes. As with V2/V3, the router does not detect the loop and relies on lower level reverts.
  - 

## Invalid V3 path length
  - **Vector**: Call `V3_SWAP_EXACT_IN` with a path that is shorter than the required 43 bytes.
  - **Result**: Reverts with `SliceOutOfBounds` from the library, demonstrating the router rejects malformed paths.
  - **Status**: Handled by the codebase.


## Mismatched Commands and Inputs
- **Description**: Call `UniversalRouter.execute` with a commands array that does not match the length of the inputs array.
- **Result**: The router reverted with the `LengthMismatch` custom error, preventing incorrect execution.
- **Status**: Handled by the codebase.


## Sub-plan failure handling
- **Vector**: Supply a failing sub-plan wrapped with the `ALLOW_REVERT` flag and ensure execution continues.
- **Result**: Added `SubPlanRevert.test.ts` which confirms the router skips the failing sub-plan and processes subsequent commands without reverting.


## Reentrancy during WETH deposit
- **Vector**: Attempted reentrancy through a malicious WETH implementation when depositing.
- **Result**: Existing `ReenteringWETH` test shows reentrancy is prevented by the lock mechanism.


## Address Collision with `ADDRESS_THIS`
- **Description**: Commands that accept a recipient interpret address `0x0000000000000000000000000000000000000002` as a sentinel value meaning `address(this)`. An honest user who wishes to send tokens to that address would instead transfer tokens to the router itself.
- **Test**: Added `AddressCollision.t.sol` that transfers ERC20 tokens to address `0x2` using the `TRANSFER` command.
- **Result**: Tokens were retained by the router and not delivered to address `0x2`.
- **Outcome**: Bug discovered. The router misroutes transfers when the recipient equals the sentinel constant.


| Vector | Result |
|-------|-------|
| Calling `permit2TransferFrom` with `AllowanceTransferDetails.from` not matching the provided owner | Reverts with `FromAddressIsNotOwner`, as expected |

| Vector | Description | Result |
|-------|-------------|-------|
| Reentrancy via WETH deposit | A malicious WETH token calls the router again during `deposit()`. The router's reentrancy lock caused the call to revert with `NotAllowedReenter`. | Handled |
| Invalid payPortion bips | Calling `payPortion` with >10000 bips causes a revert via `InvalidBips`. | Handled |


## Deadline Bypass via Two-Argument Execute
- **Vector**: Call `execute(bytes,bytes[])` directly without providing a deadline.
- **Result**: Execution succeeds even though a past deadline would cause `execute(bytes,bytes[],uint256)` to revert.
- **Test**: `UniversalRouter.test.ts` includes a new case "allows bypassing the deadline by calling the two-argument execute".
- **Outcome**: Bug discovered – the router's deadline check can be skipped.


## Duplicate tokens in V2 path
  - **Vector**: Use a Uniswap v2 path with identical tokens such as `[WETH, WETH]`.
  - **Result**: The router attempts to access a non-existent pair and reverts with a generic error instead of `V2InvalidPath`.
  - **Bug?**: Yes. The router fails to validate identical-token paths.

## Forced ETH via Self-Destruct
- **Vector**: Send ETH to the router via a contract that self-destructs.
- **Result**: ETH is received without calling `receive()` and the balance increases.
- **Test**: `ForceETH.t.sol` self-destructs to the router and asserts the balance.
- **Outcome**: Handled – forced transfers are possible but do not break router logic.


## Invalid V2 path length
  - **Vector**: Provide a V2 swap path with fewer than two tokens.
  - **Result**: The router reverts with `V2InvalidPath` as soon as execution begins.
  - **Status**: **Handled** – path length is validated correctly.


## Balance check using MSG_SENDER
  - **Vector**: Call `BALANCE_CHECK_ERC20` with the owner argument set to the sentinel `MSG_SENDER`.
  - **Result**: The router checks the balance of address `0x1` instead of the caller and reverts with `BalanceTooLow`.
  - **Bug?**: Yes. The command does not map sentinel addresses and fails for valid callers.
## Reentrancy via WETH withdraw
- **Vector**: Use a malicious WETH token whose `withdraw()` function attempts to call the router again.
- **Result**: The reentrant call is rejected with `ContractLocked`, causing the malicious token to revert with `NotAllowedReenter`.
- **Test**: `ReentrancyWithdraw.t.sol` demonstrates the revert.
- **Status**: Handled – the reentrancy guard stops reentry during WETH withdrawal.


## Duplicate tokens in V3 path
  - **Vector**: Provide a Uniswap v3 path where the same token appears twice (e.g. `[WETH, 3000, WETH]`) when calling `V3_SWAP_EXACT_IN`.
  - **Result**: The router calls into a pool address that does not exist and the transaction reverts without a helpful error message.
  - **Bug?**: Yes. There is no validation that the two tokens differ when building the v3 path.


## MaxInputAmount reset on revert
  - **Vector**: Call `V3_SWAP_EXACT_OUT` with an amountOut that causes the swap to revert, then perform a valid swap.
  - **Result**: The second swap succeeds, demonstrating the `MaxInputAmount` transient storage was cleared when the first call reverted.
  - **Status**: Handled – reverting a swap does not leave stale values in transient storage.

## MaxInputAmount revert before clearing
  - **Vector**: Trigger a revert inside `V3_SWAP_EXACT_OUT` before the call resets `MaxInputAmount`.
  - **Result**: `MaxInputAmountRouterReset.t.sol` shows the value is zero after the revert, so the storage does not persist.
  - **Status**: Handled – the transient slot is cleared on failure.


## Balance check using ADDRESS_THIS
  - **Vector**: Call `BALANCE_CHECK_ERC20` with the owner argument set to the sentinel `ADDRESS_THIS`.
  - **Result**: The router checks the balance of address `0x2` rather than its own address and reverts with `BalanceTooLow`.
  - **Bug?**: Yes. The command fails to map the `ADDRESS_THIS` sentinel to `address(this)`.

## WrapETH using CONTRACT_BALANCE after forced ETH
  - **Vector**: Force ETH into the router via a self-destructing contract then call `WRAP_ETH` with amount `CONTRACT_BALANCE`.
  - **Result**: The router wraps all ETH it holds, including the forced funds, and transfers WETH to the caller.
  - **Status**: Handled – forced ETH can be withdrawn but no user funds are at risk.

## V4 Position Manager call forwards entire ETH balance
  - **Vector**: Force ETH into the router and invoke `V4_POSITION_MANAGER_CALL` with a basic `modifyLiquidities` call.
  - **Result**: The router forwarded all ETH it held to the position manager, demonstrating the entire balance is sent.
  - **Status**: Handled – behaviour confirmed in `V4PositionManagerValue.t.sol` but may be unexpected.

## Reentrancy via ERC20 transfer
  - **Vector**: Use an ERC20 token whose `transfer` function reenters the router during a `TRANSFER` command.
  - **Result**: The reentrant call is rejected with `ContractLocked` and the token transaction reverts.
  - **Status**: Handled – the router's lock prevents reentrancy during ERC20 transfers.
## TRANSFER using CONTRACT_BALANCE with ETH
- **Vector**: Call `TRANSFER` with the token set to `ETH` and the amount set to `CONTRACT_BALANCE`.
- **Result**: The router attempts to send `2^255` wei and reverts with `ETH_TRANSFER_FAILED` because the value exceeds its balance.
- **Status**: Handled – the call reverts preventing misuse of the flag with ETH.

## Duplicate tokens in V3 path (exact output)
  - **Vector**: Provide a Uniswap v3 path with identical tokens such as `[WETH, 3000, WETH]` when calling `V3_SWAP_EXACT_OUT`.
  - **Result**: The router attempts to access a non-existent pool and reverts. Tested in `UniswapV3DuplicateTokenExactOut.t.sol`.
  - **Status**: Handled – the router fails on an invalid pool address.

## Duplicate tokens in V4 path
  - **Vector**: Supply a V4 swap path where a pool key uses the same token for both `currency0` and `currency1`.
  - **Result**: The router forwards the malformed pool key to the pool manager which reverts, demonstrating no validation occurs.
  - **Bug?**: Yes. The router relies on pool manager errors instead of rejecting invalid paths.


## ETH Sent with Empty Commands
- **Vector**: Call `execute` with no commands but send ETH in the transaction.
- **Result**: The ETH remains in the router and can be swept by any address using the `SWEEP` command.
- **Status**: Handled – funds are not automatically returned but are withdrawable by anyone.


## Nonexistent V2 pair
  - **Vector**: Attempt a V2 swap using tokens that do not have an existing pair.
  - **Result**: The router transfers tokens to the computed pair address and then reverts when calling `getReserves`, leaving the funds stuck.
  - **Bug?**: Yes. Pair existence is not checked before transferring funds.