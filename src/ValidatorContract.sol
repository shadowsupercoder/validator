// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ValidatorContract {
    IERC721 public licenseToken;
    IERC20 public rewardToken;

    uint256 public epochDuration;
    uint256 public epochEndTimestamp;
    uint256 public totalReward;
    uint256 public rewardDecay; // e.g., 10% as 10

    struct Validator {
        uint256 lockedLicense;
        uint256 lockTimestamp;
        uint256 rewards;
    }

    mapping(address => Validator) public validators;
    uint256 public totalLocked;

    event LicenseLocked(address indexed validator, uint256 tokenId);
    event LicenseUnlocked(address indexed validator, uint256 tokenId);
    event RewardsClaimed(address indexed validator, uint256 amount);
    event EpochEnded(uint256 epochEnd, uint256 rewardPool);

    constructor(
        address _licenseToken,
        address _rewardToken,
        uint256 _epochDuration,
        uint256 _initialReward,
        uint256 _rewardDecay
    ) {
        licenseToken = IERC721(_licenseToken);
        rewardToken = IERC20(_rewardToken);
        epochDuration = _epochDuration;
        totalReward = _initialReward;
        rewardDecay = _rewardDecay;
        epochEndTimestamp = block.timestamp + epochDuration;
    }

    modifier onlyAfterEpochEnd() {
        require(block.timestamp >= epochEndTimestamp, "Epoch not ended yet");
        _;
    }

    function lockLicense(uint256 tokenId) external {
        require(validators[msg.sender].lockedLicense == 0, "Already locked");
        licenseToken.transferFrom(msg.sender, address(this), tokenId);
        validators[msg.sender] = Validator({
            lockedLicense: tokenId,
            lockTimestamp: block.timestamp,
            rewards: 0
        });
        totalLocked += 1;

        emit LicenseLocked(msg.sender, tokenId);
    }

    function unlockLicense() external {
        Validator storage validator = validators[msg.sender];
        require(validator.lockedLicense != 0, "No license locked");
        require(
            block.timestamp >= validator.lockTimestamp + epochDuration,
            "Must wait one full epoch"
        );

        uint256 tokenId = validator.lockedLicense;
        validator.lockedLicense = 0;
        totalLocked -= 1;
        licenseToken.transferFrom(address(this), msg.sender, tokenId);

        emit LicenseUnlocked(msg.sender, tokenId);
    }

    function claimRewards() external {
        Validator storage validator = validators[msg.sender];
        require(validator.rewards > 0, "No rewards available");

        uint256 amount = validator.rewards;
        validator.rewards = 0;
        rewardToken.transfer(msg.sender, amount);

        emit RewardsClaimed(msg.sender, amount);
    }

    function epochEnd() external onlyAfterEpochEnd {
        if (totalLocked > 0) {
            uint256 rewardPerValidator = totalReward / totalLocked;
            for (uint256 i = 0; i < totalLocked; i++) {
                address validatorAddress = address(uint160(i)); // Example for distribution
                validators[validatorAddress].rewards += rewardPerValidator;
            }
        }

        totalReward = (totalReward * (100 - rewardDecay)) / 100;
        epochEndTimestamp = block.timestamp + epochDuration;

        emit EpochEnded(epochEndTimestamp, totalReward);
    }
}
