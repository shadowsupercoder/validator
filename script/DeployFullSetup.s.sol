// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ValidatorContract.sol";
import "../src/ERC20RewardToken.sol";
import "../src/ERC721LicenseToken.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
    This script can be used to deploy test tokens, mint some of then to the
    provided address RECEIVER and deployer, then deploy the Validator SC
    Script Workflow:
    1. Deploy ERC20 Reward Token:
        - Deploys an ERC20 token contract.
        - Mints the initial supply to the deployer's address. // in case if needed to use further
    2. Deploy ERC721 License Token:
        - Deploys an ERC721 token contract.
        - Provides a mint function for minting licenses.
    3. Mint Tokens to Users:
        - Mints a specified amount of ERC20 tokens to the recipient's address.
        - Mints 5 ERC721 tokens (licenses) to the recipient's address.
    4. Deploy ValidatorContract:
        - Deploys the ValidatorContract with the deployed ERC20 and ERC721 contract addresses.

    Run the Deployment Script: Use the following Foundry command to execute the script:

    forge script script/DeployFullSetup.s.sol \
    --rpc-url <YOUR_RPC_URL> \  
    --private-key <YOUR_PRIVATE_KEY> \
    --verify \
    --etherscan-api-key <YOUR_ETHERSCAN_API_KEY> \
    --chain-id <CHAIN_ID> \
    --broadcast
    
    Breakdown of Flags:
    --verify: Enables verification for deployed contracts.
    --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>: Supplies your Etherscan (or other explorer's) API key.
    --rpc-url <YOUR_RPC_URL>: Specifies the blockchain RPC endpoint.
    --private-key <YOUR_PRIVATE_KEY>: Uses the deployer wallet's private key.
    --chain-id <CHAIN_ID>: Identifies the target blockchain network (e.g., Ethereum Mainnet, Goerli, etc.).
    --broadcast: Broadcasts the deployment transactions to the network.
*/
contract DeployFullSetup is Script {
    function run() external {
        address RECEIVER = 0xe0155280394287C02938BC47aaFc3390e4DbEdA6; // Replace with actual recipient address

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy ERC20 reward token
        ERC20 rewardToken = new ERC20RewardToken();
        console.log("ERC20 Reward Token deployed at:", address(rewardToken));

        // Deploy ERC721 license token
        ERC721 licenseToken = new ERC721LicenseToken();
        console.log("ERC721 License Token deployed at:", address(licenseToken));

        // Mint ERC20 tokens to the provided address (example)
        uint256 rewardAmount = 1_000_000 * 10 ** 18; // 1 million tokens
        rewardToken.transfer(RECEIVER, rewardAmount);
        console.log("Minted", rewardAmount, "ERC20 tokens to:", RECEIVER);

        // Mint ERC721 licenses to the provided address
        for (uint256 i = 1; i <= 5; i++) {
            ERC721LicenseToken(address(licenseToken)).mint(RECEIVER, i);
            console.log("Minted ERC721 token ID:", i, "to:", RECEIVER);
        }

        // Deploy ValidatorContract
        uint256 epochDuration = 3600; // 1 hour in seconds
        uint256 initialReward = 1000; // Initial reward per epoch
        uint256 rewardDecay = 10; // 10% reward decay per epoch

        ValidatorContract validatorContract = new ValidatorContract(
            address(licenseToken),
            address(rewardToken),
            epochDuration,
            initialReward,
            rewardDecay
        );
        console.log(
            "ValidatorContract deployed at:",
            address(validatorContract)
        );

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
