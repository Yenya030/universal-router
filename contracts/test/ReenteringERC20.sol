// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import {ERC20} from 'solmate/src/tokens/ERC20.sol';

/// @notice ERC20 token that attempts to reenter the UniversalRouter on transfer
contract ReenteringERC20 is ERC20 {
    error NotAllowedReenter();

    address public universalRouter;
    bytes public data;

    constructor() ERC20('ReenteringERC20', 'RERC', 18) {}

    function setParameters(address _universalRouter, bytes memory _data) external {
        universalRouter = _universalRouter;
        data = _data;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        bool ok = super.transfer(to, amount);
        (bool success,) = universalRouter.call(data);
        if (!success) revert NotAllowedReenter();
        return ok;
    }
}
