# Tested Attack Vectors

| Vector | Description | Result |
|-------|-------------|-------|
| Reentrancy via WETH deposit | A malicious WETH token calls the router again during `deposit()`. The router's reentrancy lock caused the call to revert with `NotAllowedReenter`. | Handled |
| Invalid payPortion bips | Calling `payPortion` with >10000 bips causes a revert via `InvalidBips`. | Handled |
