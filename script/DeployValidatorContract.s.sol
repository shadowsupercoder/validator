// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ValidatorContract.sol";

/**
    This script can be used if you already have the token addresses

    Steps to Use the Deployment Script
    Set Contract Parameters:

    Replace 0xYourERC721TokenAddress and 0xYourERC20TokenAddress with the actual deployed addresses of your ERC721 and ERC20 tokens.
    Adjust epochDuration, initialReward, and rewardDecay as required.
    Run the Deployment Script: Use the following Foundry command to execute the script:

    forge script script/DeployValidatorContract.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast

    <YOUR_RPC_URL>: The RPC URL for the blockchain network (e.g., Infura, Alchemy).
    <YOUR_PRIVATE_KEY>: The private key of the deployer wallet.

    Verify the Deployment: After deployment, you’ll see the contract address in the console output.
    forge verify-contract --chain-id <CHAIN_ID> --contract src/ValidatorContract.sol:ValidatorContract <DEPLOYED_CONTRACT_ADDRESS> <ETHERSCAN_API_KEY>
    Replace <CHAIN_ID>, <DEPLOYED_CONTRACT_ADDRESS>, and <ETHERSCAN_API_KEY> with the appropriate values.

*/
contract DeployValidatorContract is Script {
    function run() external {
        // Start broadcasting transactions to the network
        vm.startBroadcast();

        // Define initial parameters for the ValidatorContract
        address licenseToken = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D; // Replace with actual ERC721 token address
        address rewardToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;   // Replace with actual ERC20 token address
        uint256 epochDuration = 3600; // Epoch duration in seconds (e.g., 1 hour)
        uint256 initialReward = 1000 * 10**18; // Initial reward (scaled to token decimals)
        uint256 rewardDecay = 10; // 10% reward decay per epoch

        // Deploy the contract
        ValidatorContract validatorContract = new ValidatorContract(
            licenseToken,
            rewardToken,
            epochDuration,
            initialReward,
            rewardDecay
        );

        // Log the deployed contract's address
        console.log("ValidatorContract deployed at:", address(validatorContract));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
