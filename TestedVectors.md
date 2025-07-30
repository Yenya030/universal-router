# Tested Attack Vectors

| Vector | Result |
|-------|-------|
| Calling `permit2TransferFrom` with `AllowanceTransferDetails.from` not matching the provided owner | Reverts with `FromAddressIsNotOwner`, as expected |
