let provider;
let signer;
let contract;
let userAddress;

const contractAddress = "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318"; // Replace with your deployed contract address
const abi = [
  "function transfer(address recipient, uint256 amount) public returns (bool)",
  "function setTransferFee(uint fee) external",
  "function stake(uint256 amount) external",
  "function unstake(uint256 amount) external",
  "function claimRewards() external",
  "function balanceOf(address account) public view returns (uint256)",
  "function totalStaked() public view returns (uint256)",
  "function rewardRate() public view returns (uint256)",
  "function getStakeInfo(address staker) external view returns (uint256 amount, uint256 timestamp, uint256 pendingRewards)",
  // Add getters since transferFee and owner are private
  "function getTransferFee() public view returns (uint)", // Add this to the contract
  "function getOwner() public view returns (address)", // Add this to the contract
];

// Connect to wallet
document
  .getElementById("connect-wallet")
  .addEventListener("click", async () => {
    if (window.ethereum) {
      provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = provider.getSigner();
      userAddress = await signer.getAddress();
      contract = new ethers.Contract(contractAddress, abi, signer);

      document.getElementById("user-address").textContent = userAddress;
      await updateUI();
    } else {
      alert("Please install MetaMask!");
    }
  });

// Update UI with initial data
async function updateUI() {
  await updateBalance();
  await updateTransferFee();
  await updateStakingInfo();
  await checkOwner();
}

// Update user's balance
async function updateBalance() {
  const balance = await contract.balanceOf(userAddress);
  document.getElementById("user-balance").textContent =
    ethers.utils.formatUnits(balance, 18);
}

// Update transfer fee and related displays
async function updateTransferFee() {
  const transferFee = await contract.getTransferFee();
  const feePercentage = (transferFee / 100).toFixed(2);
  document.getElementById("transfer-fee").textContent = feePercentage;
}

// Update staking information
async function updateStakingInfo() {
  const [amount, , pendingRewards] = await contract.getStakeInfo(userAddress);
  const totalStaked = await contract.totalStaked();
  const rewardRate = await contract.rewardRate();
  const annualPercentage = (rewardRate / 10).toFixed(2);

  document.getElementById("staked-amount").textContent =
    ethers.utils.formatUnits(amount, 18);
  document.getElementById("pending-rewards").textContent =
    ethers.utils.formatUnits(pendingRewards, 18);
  document.getElementById("total-staked").textContent =
    ethers.utils.formatUnits(totalStaked, 18);
  document.getElementById("reward-rate").textContent = annualPercentage;
}

// Check if user is the owner
async function checkOwner() {
  const owner = await contract.getOwner();
  if (userAddress.toLowerCase() === owner.toLowerCase()) {
    document.getElementById("owner-controls").style.display = "block";
    document.getElementById("set-fee-form").style.display = "block";
  } else {
    document.getElementById("owner-controls").style.display = "block"; // Always show the owner controls section
    document.getElementById("set-fee-form").style.display = "none"; // But hide the set fee form
  }
}

// Handle transfer form submission
document
  .getElementById("transfer-form")
  .addEventListener("submit", async (e) => {
    e.preventDefault();
    const recipient = document.getElementById("recipient").value;
    const amount = document.getElementById("amount").value;
    const weiAmount = ethers.utils.parseUnits(amount, 18);

    try {
      const tx = await contract.transfer(recipient, weiAmount);
      await tx.wait();
      alert("Transfer successful");
      await updateBalance();
    } catch (error) {
      alert("Transfer failed: " + error.message);
    }
  });

// Dynamically update fee and net amount on input
document.getElementById("amount").addEventListener("input", async () => {
  const amount = document.getElementById("amount").value;
  if (amount) {
    const weiAmount = ethers.utils.parseUnits(amount, 18);
    const transferFee = await contract.getTransferFee();
    const fee = weiAmount.mul(transferFee).div(10000);
    const netAmount = weiAmount.sub(fee);
    document.getElementById("fee-amount").textContent =
      ethers.utils.formatUnits(fee, 18);
    document.getElementById("net-amount").textContent =
      ethers.utils.formatUnits(netAmount, 18);
  } else {
    document.getElementById("fee-amount").textContent = "0";
    document.getElementById("net-amount").textContent = "0";
  }
});

// Handle set transfer fee
document
  .getElementById("set-fee-form")
  .addEventListener("submit", async (e) => {
    e.preventDefault();
    const newFee = document.getElementById("new-fee").value;
    try {
      const tx = await contract.setTransferFee(newFee);
      await tx.wait();
      alert("Transfer fee updated");
      await updateTransferFee();
    } catch (error) {
      alert("Failed to set transfer fee: " + error.message);
    }
  });

// Handle stake form submission
document.getElementById("stake-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const amount = document.getElementById("stake-amount").value;
  const weiAmount = ethers.utils.parseUnits(amount, 18);

  try {
    const tx = await contract.stake(weiAmount);
    await tx.wait();
    alert("Stake successful");
    await updateBalance();
    await updateStakingInfo();
  } catch (error) {
    alert("Stake failed: " + error.message);
  }
});

// Handle unstake form submission
document
  .getElementById("unstake-form")
  .addEventListener("submit", async (e) => {
    e.preventDefault();
    const amount = document.getElementById("unstake-amount").value;
    const weiAmount = ethers.utils.parseUnits(amount, 18);

    try {
      const tx = await contract.unstake(weiAmount);
      await tx.wait();
      alert("Unstake successful");
      await updateBalance();
      await updateStakingInfo();
    } catch (error) {
      alert("Unstake failed: " + error.message);
    }
  });

// Handle claim rewards
document.getElementById("claim-rewards").addEventListener("click", async () => {
  try {
    const tx = await contract.claimRewards();
    await tx.wait();
    alert("Rewards claimed successfully");
    await updateBalance();
    await updateStakingInfo();
  } catch (error) {
    alert("Claim rewards failed: " + error.message);
  }
});
