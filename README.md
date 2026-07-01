# Anonymous Membership Verifier DApp

Anonymous Membership Verifier DApp is a React + Vite decentralized application for proving membership with cryptographic verification on Sepolia. The app connects to MetaMask, computes a Merkle-style membership proof, and sends the proof to a smart contract while keeping the user identity private.

## What it does

- Connects a wallet through MetaMask
- Verifies an authorized member on-chain
- Uses `ethers.js` for wallet and contract interactions
- Displays transaction and verification status in the UI

## Tech Stack

- React 19
- Vite
- ethers.js v6
- Solidity smart contract backend
- Sepolia test network

## Project Structure

- `src/App.jsx` - main DApp UI and blockchain interaction logic
- `src/abi.json` - contract ABI used by the frontend
- `tests/AnonymousVerifier.sol` - smart contract source
- `tests/AnonymousVerifier_test.sol` - contract tests
- `artifacts/` - compiled contract outputs and build metadata

## Local Setup

1. Install dependencies:

```bash
npm install
```

2. Start the development server:

```bash
npm run dev
```

3. Open the local URL shown in the terminal and connect MetaMask.

## Usage

1. Connect MetaMask.
2. Ensure the wallet is on Sepolia.
3. Click the verification button.
4. Confirm the transaction in MetaMask.

## Contract Details

- Current frontend contract address: `0x61DD50a7d440311BE7cA6C6FF4F6b28c2D10Be07`
- The app expects the contract ABI from `src/abi.json`

## Notes

- This repository is suitable for GitHub portfolio presentation because it includes the app code, smart contract sources, build artifacts, and a clear project overview.
- If the contract is redeployed, update the address in `src/App.jsx`.
