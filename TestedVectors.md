# Tested Attack Vectors

This document tracks the attack vectors evaluated against the repository and the results of testing each vector.

## 1. Allow Revert Flag Handling
- **Vector**: Use the `FLAG_ALLOW_REVERT` with a command that fails internally (e.g. `PAY_PORTION` with invalid bips).
- **Result**: Failing internal commands still revert the entire transaction instead of being ignored. Verified with `AllowRevert.t.sol` test which expects a revert when the flag is set.
- **Status**: **Bug discovered** – the allow revert flag does not work for certain internal commands.

## 2. Transient Storage Persistence
- **Vector**: Reverting after calling functions that write to transient storage (e.g. `MaxInputAmount` or `Locker`) to see if the value persists and causes inconsistent state.
- **Result**: Transient storage is cleared when the transaction reverts, so no state persists after failure.
- **Status**: **Handled** – no persistent state was observed.

## 3. Overflow in `BipsLibrary.calculatePortion`
- **Vector**: Provide extremely large amounts to `calculatePortion` to test arithmetic overflow handling.
- **Result**: Solidity 0.8 built‑in overflow checks correctly revert on overflow. No unexpected behaviour observed.
- **Status**: **Handled** – library reverts as expected on overflow.
