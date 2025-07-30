pragma solidity ^0.8.24;

import {UniversalRouter} from '../../../contracts/UniversalRouter.sol';

contract ReentrantReceiver {
    UniversalRouter public router;
    bool public reentered;

    constructor(UniversalRouter _router) {
        router = _router;
    }

    receive() external payable {
        bytes memory commands = '';
        bytes[] memory inputs = new bytes[](0);
        try router.execute(commands, inputs) {
            // execution should revert due to lock
        } catch {
            reentered = true;
        }
    }
}
