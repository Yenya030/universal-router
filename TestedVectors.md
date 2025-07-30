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

