// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import {ERC20} from 'solmate/src/tokens/ERC20.sol';

contract ReenteringWETHWithdraw is ERC20 {
    error NotAllowedReenter();

    address public universalRouter;
    bytes public data;

    constructor() ERC20('ReenteringWETHWithdraw', 'RWW', 18) {}

    function setParameters(address _universalRouter, bytes memory _data) external {
        universalRouter = _universalRouter;
        data = _data;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function withdraw(uint256) public {
        (bool success,) = universalRouter.call(data);
        if (!success) revert NotAllowedReenter();
    }
}
