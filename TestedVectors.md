## Tested Attack Vectors

- **Looping V2 swap path**: Crafted a path where the last hop returns to the first token (e.g. `[token0, token1, token0]`).
  - **Result**: Transaction reverts with `UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT` showing Universal Router does not gracefully handle looping paths.
  - **Bug?**: Yes. The router fails inside the pair contract instead of validating the path and reverting early.
