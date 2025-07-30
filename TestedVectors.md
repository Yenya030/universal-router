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


## Mismatched Commands and Inputs
- **Description**: Call `UniversalRouter.execute` with a commands array that does not match the length of the inputs array.
- **Result**: The router reverted with the `LengthMismatch` custom error, preventing incorrect execution.
- **Status**: Handled by the codebase.