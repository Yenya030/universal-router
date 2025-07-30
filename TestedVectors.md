# Tested Attack Vectors

## 1. Address Collision with `ADDRESS_THIS`
- **Description**: Commands that accept a recipient interpret address `0x0000000000000000000000000000000000000002` as a sentinel value meaning `address(this)`. An honest user who wishes to send tokens to that address would instead transfer tokens to the router itself.
- **Test**: Added `AddressCollision.t.sol` that transfers ERC20 tokens to address `0x2` using the `TRANSFER` command.
- **Result**: Tokens were retained by the router and not delivered to address `0x2`.
- **Outcome**: Bug discovered. The router misroutes transfers when the recipient equals the sentinel constant.

## 2. Missing Environment Variables for Network Forks
- **Description**: Hardhat and some Foundry tests require network RPC URLs via `INFURA_API_KEY` or `FORK_URL`. Without them the test suites fail.
- **Test**: Attempted `yarn test:hardhat` and `forge test --isolate`.
- **Result**: Both commands failed due to missing API keys.
- **Outcome**: Handled by environment; not a code bug but required configuration.
