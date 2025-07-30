# Tested Attack Vectors

This document records the attack vectors that were tested during analysis.
Each entry notes whether the vector revealed a bug or was properly handled.

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

## Notes on Integration Tests
Integration tests that rely on a mainnet fork require a `FORK_URL`/`INFURA_API_KEY`. These could not be executed in the current environment, so no conclusions could be drawn about those scenarios.
