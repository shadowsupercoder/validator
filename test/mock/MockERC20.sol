// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "M20") {
        _mint(msg.sender, 1e24); // 1 million tokens
    }
}
