Below is a README file designed to guide users on how to set up and run the "erc20-midterm" project from the GitHub repository at `https://github.com/koezyrs/erc20-midterm`. This README assumes the project is an ERC20 token implementation written in Solidity, using Hardhat as the development framework—a common choice for Ethereum smart contract projects. Adjust the instructions if the repository uses a different framework (e.g., Truffle) or includes additional components like a frontend.

---

# ERC20 Midterm Project

This repository contains the implementation of an ERC20 token as part of a midterm project. The token is written in Solidity and is designed to be deployed on the Ethereum blockchain.

## Features

### Custom ERC20 Token

- Standard ERC20 functionality (transfer, balanceOf, etc.)
- Custom transfer implementation with a small fee

### Staking and Reward System

- **Staking**: Users can lock up their tokens to earn rewards over time
- **Unstaking**: Users can withdraw their staked tokens at any time
- **Rewards**: Stakers earn additional tokens automatically based on their staked amount and time
- **Reward Claiming**: Accumulated rewards can be claimed and received as newly minted tokens

#### How Staking Works

1. Users stake tokens by calling the `stake(amount)` function
2. The staked tokens are transferred from the user's wallet to the contract
3. Every 10 seconds, rewards accumulate based on the formula:
   - `reward = (staked amount * reward rate * time) / (period * 1000)`
   - With default settings, this gives approximately 10% reward over time
4. Users can claim rewards at any time through the `claimRewards()` function
5. Unstaking is possible with the `unstake(amount)` function, which returns tokens to the user's wallet

#### Owner Controls

- The contract owner can adjust the transfer fee (max 1%)
- The reward rate can be modified by the owner (max 50%)

## Prerequisites

To work with this project, ensure you have the following installed:

- **[Node.js](https://nodejs.org/)** (version 14.x or higher)
- **[npm](https://www.npmjs.com/)** (comes with Node.js)
- **[Git](https://git-scm.com/)**

You will also need a local Ethereum blockchain for development, such as **[Ganache](https://www.trufflesuite.com/ganache)**, or access to an Ethereum testnet.

## Setup Instructions

Follow these steps to set up and run the project locally:

### 1. Clone the Repository

Clone the repository to your local machine and navigate into the project directory:

```bash
git clone https://github.com/koezyrs/erc20-midterm.git
cd erc20-midterm
```

### 2. Install Dependencies

Install the required npm packages:

```bash
npm install
```

Alternatively, if the project uses Yarn:

```bash
yarn install
```

### 3. Compile the Smart Contracts

Compile the Solidity contracts using Hardhat:

```bash
npx hardhat compile
```

This will generate the contract artifacts needed for deployment.

### 4. Run a Local Blockchain

Start a local Ethereum blockchain using Hardhat's built-in network:

```bash
npx hardhat node
```

This command will launch a local Ethereum node with pre-funded accounts. Keep this terminal running in the background.

Alternatively, you can use Ganache or another local blockchain tool if preferred.

### 5. Deploy the Contracts

Deploy the contracts to the local network:

```bash
npx hardhat run scripts/deploy.js --network localhost
```

> **Note**: The deployment script may have a different name (e.g., `deploy.js`). Check the `scripts/` folder in the repository for the correct file name.

After deployment, the terminal will display the contract address. Save this address for interacting with the token.

### 6. Interact with the Contract

Use the Hardhat console to interact with the deployed contract:

```bash
npx hardhat console --network localhost
```

### 7. Interact with the Web

Open app.js and replace the `contractAddress` with your contract address.

After that, run index.html with LiveServer.

## Using the Staking Features

### In the Web Interface

1. **Connect your wallet**: Click the "Connect Wallet" button to connect MetaMask
2. **View your balance**: Check your token balance in the dashboard
3. **Stake tokens**: Enter an amount and click "Stake" to start earning rewards
4. **Monitor rewards**: Watch your pending rewards accumulate in real-time
5. **Claim rewards**: Click "Claim Rewards" to receive your earned tokens
6. **Unstake**: Withdraw your staked tokens by clicking "Unstake" and entering an amount

### Using Contract Directly

You can interact with the staking functions directly through the contract:

```javascript
// Stake tokens
await contract.stake(ethers.utils.parseUnits("100", 18));

// Check staking information
const [amount, timestamp, pendingRewards] = await contract.getStakeInfo(
  userAddress
);

// Claim rewards
await contract.claimRewards();

// Unstake tokens
await contract.unstake(ethers.utils.parseUnits("50", 18));
```

### DEMO

![img](https://i.imgur.com/qWsp06q.png)

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub repository](https://github.com/koezyrs/erc20-midterm).

## License

This project is licensed under the [License Type]. See the `LICENSE` file in the repository for details.

> **Note**: Update the license information based on the project's actual licensing. If no license is specified, this section can be omitted or clarified with the repository owner.

---

This README provides a clear, step-by-step guide to set up and run the "erc20-midterm" project. It assumes a Hardhat-based workflow, which is typical for modern Ethereum development, but you should verify the repository's structure and adjust the instructions accordingly if it uses a different framework or additional features (e.g., a frontend).
