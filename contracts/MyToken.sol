// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing the ERC20 standard token contract from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MyToken
 * @dev A custom ERC20 token contract with staking and reward features.
 * Users can stake tokens to earn rewards, unstake them, and claim rewards.
 * Inherits basic token functionality (transfer, balance, etc.) from ERC20.
 */
contract MyToken is ERC20 {
    // The address of the contract owner, who has special privileges
    address private owner;
    // Transfer fee in basis points (10/10000 = 0.1% fee per transfer)
    uint private transferFee = 10;

    // --- Staking-Related Variables ---
    // Total amount of tokens staked across all users
    uint256 public totalStaked;
    // Reward rate for staking (100/1000 = 10% reward over time)
    uint256 public rewardRate = 100;
    // Constant defining the time period for reward calculation (10 seconds)
    uint256 constant SECONDS_PER_REWAWRD = 10;

    // --- Staking Data Structure ---
    /**
     * @dev Struct to store staking details for each user.
     * - amount: How many tokens the user has staked.
     * - timestamp: When the user last staked or unstaked.
     * - lastClaimed: When the user last claimed their rewards.
     */
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lastClaimed;
    }

    // Mapping to store staking info for each user (address => Stake)
    mapping(address => Stake) public stakes;
    // Mapping to store accumulated rewards for each user (address => reward amount)
    mapping(address => uint256) public rewards;

    // --- Events ---
    // Event emitted when a user stakes tokens
    event Staked(address indexed user, uint256 amount);
    // Event emitted when a user unstakes tokens
    event Unstaked(address indexed user, uint256 amount);
    // Event emitted when a user claims their rewards
    event RewardClaimed(address indexed user, uint256 amount);

    // --- Modifier ---
    /**
     * @dev Restricts certain functions to only be callable by the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _; // Continues execution of the function after this check
    }

    // --- Constructor ---
    /**
     * @dev Initializes the token with a name, symbol, initial supply, and owner.
     * @param _initialSupply The total number of tokens minted at deployment.
     * @param _owner The address that will own the contract.
     */
    constructor(
        uint256 _initialSupply,
        address _owner
    ) ERC20("DuongDepZai", "Duong") {
        owner = _owner; // Set the contract owner
        _mint(msg.sender, _initialSupply); // Mint initial tokens to the deployer
    }

    // --- Staking Functions ---

    /**
     * @dev Allows a user to stake tokens and earn rewards over time.
     * @param amount The number of tokens to stake.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Stake amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // If the user already has a stake, update their rewards first
        if (stakes[msg.sender].amount > 0) {
            updateRewards(msg.sender);
        }

        // Transfer tokens from the user to this contract
        _transfer(msg.sender, address(this), amount);

        // Update the user's staking info
        stakes[msg.sender].amount += amount; // Add to their staked amount
        stakes[msg.sender].timestamp = block.timestamp; // Record the current time

        // If this is their first stake, set the last claimed time
        if (stakes[msg.sender].lastClaimed == 0) {
            stakes[msg.sender].lastClaimed = block.timestamp;
        }

        // Increase the total staked amount across all users
        totalStaked += amount;

        // Notify the blockchain of the staking action
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows a user to unstake (withdraw) some or all of their staked tokens.
     * @param amount The number of tokens to unstake.
     */
    function unstake(uint256 amount) external {
        require(amount > 0, "Unstake amount must be greater than zero");
        require(
            stakes[msg.sender].amount >= amount,
            "Insufficient staked amount"
        );

        // Update the user's rewards before unstaking
        updateRewards(msg.sender);

        // Reduce the user's staked amount and the total staked
        stakes[msg.sender].amount -= amount;
        totalStaked -= amount;

        // Transfer the tokens back to the user
        _transfer(address(this), msg.sender, amount);

        // If the user has no tokens left staked, reset their staking info
        if (stakes[msg.sender].amount == 0) {
            stakes[msg.sender].timestamp = 0;
            stakes[msg.sender].lastClaimed = 0;
        }

        // Notify the blockchain of the unstaking action
        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Allows a user to claim their accumulated staking rewards.
     */
    function claimRewards() external {
        // Update the user's rewards first
        updateRewards(msg.sender);

        // Get the reward amount and ensure there’s something to claim
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards available");

        // Reset the user's rewards and mint new tokens as their reward
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);

        // Notify the blockchain of the reward claim
        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Calculates the rewards a user has earned based on their stake and time.
     * @param staker The address of the user to calculate rewards for.
     * @return The total reward amount (pending + accumulated).
     */
    function calculateRewards(address staker) public view returns (uint256) {
        Stake memory userStake = stakes[staker]; // Get the user's stake info
        if (userStake.amount == 0) return 0; // No stake, no rewards

        // Calculate how long the tokens have been staked since the last claim
        uint256 stakingDuration = block.timestamp - userStake.lastClaimed;

        // Reward formula: (staked amount * reward rate * time) / (period * 1000)
        uint256 reward = (userStake.amount * rewardRate * stakingDuration) /
            (SECONDS_PER_REWAWRD * 1000);

        // Add any previously accumulated rewards
        return reward + rewards[staker];
    }

    /**
     * @dev Internal function to update a user's rewards before staking/unstaking/claiming.
     * @param staker The address of the user whose rewards need updating.
     */
    function updateRewards(address staker) internal {
        uint256 reward = calculateRewards(staker); // Calculate current rewards
        if (reward > 0) {
            rewards[staker] = reward; // Store the updated reward
            stakes[staker].lastClaimed = block.timestamp; // Reset the claim timer
        }
    }

    // --- Owner-Only Functions ---

    /**
     * @dev Allows the owner to set a new transfer fee (max 1%).
     * @param fee The new fee in basis points (e.g., 100 = 1%).
     */
    function setTransferFee(uint fee) external onlyOwner {
        require(fee <= 100, "Fee cannot exceed 10%");
        transferFee = fee; // Update the transfer fee
    }

    /**
     * @dev Allows the owner to set a new reward rate (max 50%).
     * @param newRate The new reward rate (e.g., 500 = 50%).
     */
    function setRewardRate(uint newRate) external onlyOwner {
        require(newRate <= 500, "Reward rate cannot exceed 50%");
        rewardRate = newRate; // Update the reward rate
    }

    // --- Transfer Function ---

    /**
     * @dev Overrides the ERC20 transfer function to include a fee.
     * @param recipient The address receiving the tokens.
     * @param amount The total amount of tokens to transfer (including fee).
     * @return True if the transfer succeeds.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Calculate the fee and the amount the recipient gets
        uint256 fee = (amount * transferFee) / 10000; // Fee in basis points
        uint256 amountAfterFee = amount - fee; // Amount after deducting fee

        // Transfer the net amount to the recipient
        _transfer(msg.sender, recipient, amountAfterFee);
        // Transfer the fee to the owner
        _transfer(msg.sender, owner, fee);

        return true; // Indicate the transfer was successful
    }

    // --- View Functions ---

    /**
     * @dev Returns staking details for a specific user.
     * @param staker The address of the user to query.
     * @return amount The number of tokens staked.
     * @return timestamp The time of the last stake/unstake.
     * @return pendingRewards The rewards available to claim.
     */
    function getStakeInfo(
        address staker
    )
        external
        view
        returns (uint256 amount, uint256 timestamp, uint256 pendingRewards)
    {
        return (
            stakes[staker].amount, // Staked amount
            stakes[staker].timestamp, // Last stake/unstake time
            calculateRewards(staker) // Pending rewards
        );
    }

    /**
     * @dev Returns the current transfer fee.
     * @return The transfer fee in basis points (e.g., 10 = 0.1%).
     */
    function getTransferFee() public view returns (uint) {
        return transferFee;
    }

    /**
     * @dev Returns the address of the contract owner.
     * @return The owner’s address.
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}
