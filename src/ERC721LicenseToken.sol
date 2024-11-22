// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721LicenseToken is ERC721 {
    constructor() ERC721("LicenseToken", "LCT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
