# Tested Attack Vectors

This document tracks manual and automated attack vectors that have been exercised against the Universal Router contracts.

## Sub-plan failure handling
- **Vector**: Supply a failing sub-plan wrapped with the `ALLOW_REVERT` flag and ensure execution continues.
- **Result**: Added `SubPlanRevert.test.ts` which confirms the router skips the failing sub-plan and processes subsequent commands without reverting.

## Reentrancy during WETH deposit
- **Vector**: Attempted reentrancy through a malicious WETH implementation when depositing.
- **Result**: Existing `ReenteringWETH` test shows reentrancy is prevented by the lock mechanism.
