# Tested Attack Vectors

This document lists the attack vectors explored in tests.

## Transfer to reserved addresses
- **Vector:** Attempt to transfer ERC20 tokens to address `0x0000000000000000000000000000000000000001` via the router.
- **Finding:** Tokens are incorrectly sent to the caller instead of the intended address. This occurs because the router maps address `1` to `MSG_SENDER`.
- **Test:** `testTransferToReservedAddress` in `test/foundry-tests/UniversalRouter.t.sol` demonstrates the issue.

## Sweep commands
- **Vector:** Sweeping tokens and ETH with insufficient balances.
- **Finding:** Router correctly reverts with `InsufficientToken` or `InsufficientETH`.
- **Tests:** `testSweepTokenInsufficientOutput` and `testSweepETHInsufficientOutput`.

## Reentrancy
- **Vector:** Reenter router via malicious contract.
- **Finding:** Could not verify due to missing fork URL; existing tests in the repository cover this case.
