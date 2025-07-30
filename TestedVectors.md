# Tested Attack Vectors

This document tracks security related test cases executed against the code base.

## 1. Mismatched Commands and Inputs
- **Description**: Call `UniversalRouter.execute` with a commands array that does not match the length of the inputs array.
- **Result**: The router reverted with the `LengthMismatch` custom error, preventing incorrect execution.
- **Status**: Handled by the codebase.
