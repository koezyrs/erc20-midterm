Below is a README file designed to guide users on how to set up and run the "erc20-midterm" project from the GitHub repository at `https://github.com/koezyrs/erc20-midterm`. This README assumes the project is an ERC20 token implementation written in Solidity, using Hardhat as the development framework—a common choice for Ethereum smart contract projects. Adjust the instructions if the repository uses a different framework (e.g., Truffle) or includes additional components like a frontend.

---

# ERC20 Midterm Project

This repository contains the implementation of an ERC20 token as part of a midterm project. The token is written in Solidity and is designed to be deployed on the Ethereum blockchain.

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

### DEMO

![img](https://i.imgur.com/tGjpZzE.png)

## Contributing

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub repository](https://github.com/koezyrs/erc20-midterm).

## License

This project is licensed under the [License Type]. See the `LICENSE` file in the repository for details.

> **Note**: Update the license information based on the project's actual licensing. If no license is specified, this section can be omitted or clarified with the repository owner.

---

This README provides a clear, step-by-step guide to set up and run the "erc20-midterm" project. It assumes a Hardhat-based workflow, which is typical for modern Ethereum development, but you should verify the repository’s structure and adjust the instructions accordingly if it uses a different framework or additional features (e.g., a frontend).
