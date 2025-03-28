// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address private owner;
    uint private transferFee = 10; // 0.1% fee (10/10000)

    // Staking variables
    uint256 public totalStaked;
    uint256 public rewardRate = 100; // 10% annual reward (100/1000)
    uint256 constant SECONDS_PER_YEAR = 31536000; // 365 days in seconds

    // Staking structures
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lastClaimed;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(
        uint256 _initialSupply,
        address _owner
    ) ERC20("DuongDepZai", "Duong") {
        owner = _owner;
        _mint(msg.sender, _initialSupply);
    }

    // Staking functions
    function stake(uint256 amount) external {
        require(amount > 0, "Stake amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Update existing stake rewards
        if (stakes[msg.sender].amount > 0) {
            updateRewards(msg.sender);
        }

        // Transfer tokens to contract and update stake
        _transfer(msg.sender, address(this), amount);
        stakes[msg.sender].amount += amount;
        stakes[msg.sender].timestamp = block.timestamp;
        if (stakes[msg.sender].lastClaimed == 0) {
            stakes[msg.sender].lastClaimed = block.timestamp;
        }

        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Unstake amount must be greater than zero");
        require(
            stakes[msg.sender].amount >= amount,
            "Insufficient staked amount"
        );

        // Update rewards before unstaking
        updateRewards(msg.sender);

        // Update stake and transfer tokens back
        stakes[msg.sender].amount -= amount;
        totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);

        if (stakes[msg.sender].amount == 0) {
            stakes[msg.sender].timestamp = 0;
            stakes[msg.sender].lastClaimed = 0;
        }

        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external {
        updateRewards(msg.sender);
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards available");

        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateRewards(address staker) public view returns (uint256) {
        Stake memory userStake = stakes[staker];
        if (userStake.amount == 0) return 0;

        uint256 stakingDuration = block.timestamp - userStake.lastClaimed;
        uint256 reward = (userStake.amount * rewardRate * stakingDuration) /
            (SECONDS_PER_YEAR * 1000);
        return reward + rewards[staker];
    }

    function updateRewards(address staker) internal {
        uint256 reward = calculateRewards(staker);
        if (reward > 0) {
            rewards[staker] = reward;
            stakes[staker].lastClaimed = block.timestamp;
        }
    }

    // Original functions with modifications
    function setTransferFee(uint fee) external onlyOwner {
        require(fee <= 100, "Fee cannot exceed 10%");
        transferFee = fee;
    }

    function setRewardRate(uint newRate) external onlyOwner {
        require(newRate <= 500, "Reward rate cannot exceed 50%");
        rewardRate = newRate;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 fee = (amount * transferFee) / 10000;
        uint256 amountAfterFee = amount - fee;

        _transfer(msg.sender, recipient, amountAfterFee);
        _transfer(msg.sender, owner, fee);
        return true;
    }

    // View functions
    function getStakeInfo(
        address staker
    )
        external
        view
        returns (uint256 amount, uint256 timestamp, uint256 pendingRewards)
    {
        return (
            stakes[staker].amount,
            stakes[staker].timestamp,
            calculateRewards(staker)
        );
    }

    // Getter for private transferFee
    function getTransferFee() public view returns (uint) {
        return transferFee;
    }

    // Getter for private owner
    function getOwner() public view returns (address) {
        return owner;
    }
}
