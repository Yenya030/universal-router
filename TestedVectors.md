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
