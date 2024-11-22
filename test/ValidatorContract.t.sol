// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ValidatorContract.sol";
import "./mock/MockERC721.sol";
import "./mock/MockERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ValidatorContractTest is Test {
    ValidatorContract public validatorContract;
    MockERC721 public licenseToken;
    MockERC20 public rewardToken;

    function setUp() public {
        licenseToken = new MockERC721();
        rewardToken = new MockERC20();
        validatorContract = new ValidatorContract(
            address(licenseToken),
            address(rewardToken),
            3600,  // 1-hour epoch
            1000,  // Initial reward
            10     // 10% reward decay
        );
    }

    function testLockLicense() public {
        licenseToken.mint(address(this), 1);
        licenseToken.approve(address(validatorContract), 1);
        validatorContract.lockLicense(1);

        assertEq(licenseToken.ownerOf(1), address(validatorContract));
    }

    // Add tests for unlocking licenses, claiming rewards, and epoch handling
}
