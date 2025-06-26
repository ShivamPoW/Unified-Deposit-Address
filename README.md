# Unified Deposit Address - Simple Implementation

A simple, modern implementation of a unified deposit address system using EIP-7702 to upgrade EOAs to smart contracts for automatic USDC relaying across multiple blockchain networks.
> Checkout contracts and transactions on [Arbiscan](https://sepolia.arbiscan.io/address/0xbb7a3502defdcf0502bb6e082d744567b903034b) and [Etherscan](https://sepolia.etherscan.io/address/0xbb7a3502defdcf0502bb6e082d744567b903034b). 

## Overview

This system enables a single deposit address (an EOA wallet) to be upgraded to a smart contract on multiple chains using EIP-7702. Any USDC or ETH sent to this address on any supported chain is automatically forwarded to a predefined recipient, with a backend service handling monitoring and relaying.



## Features

- **Unified Deposit Address:** One EOA for all chains, upgradable to a smart contract via EIP-7702.
- **Multi-Chain Support:** Works on Sepolia and Arbitrum Sepolia testnets (easily extendable).
- **Automatic USDC/ETH Relaying:** All deposits are automatically forwarded to a recipient.
- **Whitelisted Relayer:** Only authorized relayers can trigger forwarding.
- **Modern Solidity & Tooling:** Uses Foundry, OpenZeppelin, and Etherscan V2 API.
- **Backend Monitoring:** Node.js backend watches for deposits and triggers relays.
- **Clear, Minimal, and Extensible:** Focused on assignment requirements, but ready for future growth.


## Prerequisites

- Foundry (latest version)
- Node.js 18+
- Git
- Etherscan API key (V2, works for all supported chains)
- Testnet ETH and USDC for your unified deposit EOA


## Key Architecture Correction (IMPORTANT)

**Unified Deposit uses a proxy pattern:**
- The **implementation contract** (logic) and the **unified deposit address (proxy/EOA)** must be different addresses.
- The EOA is upgraded to a contract wallet (proxy) using EIP-7702, which delegates all logic to the implementation contract.
- The proxy (unified address) holds funds and has its own storage (owner, recipient, relayer whitelist, etc.).
- The implementation contract is only for logic and should never hold funds directly.


## Quick Start (Optimized)

### 1. Deploy Implementation Contract

```bash
# Deploy to Sepolia
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# Deploy to Arbitrum Sepolia
forge script script/Deploy.s.sol --rpc-url $ARBITRUM_SEPOLIA_RPC_URL --broadcast --verify
```

### 2. Upgrade EOA to Proxy (EIP-7702)

- Use EIP-7702 tooling to upgrade your EOA (unified deposit address) to a contract wallet (proxy) that delegates to the implementation contract.
- After upgrade, your EOA address will have contract code and will delegate all calls to the implementation.

### 3. Initialize Proxy Storage

- Call `setRecipient` to set the recipient address.
- Call `setRelayer` to whitelist the relayer (usually the EOA itself).
- (If needed) Call `transferOwnership` to set the owner.

### 4. Run Backend

```bash
cd backend
npm install
npm start
```


## Common Pitfalls & Troubleshooting

- **Do NOT use the same address for both implementation and proxy.**
- **If all transactions revert:**
  - Check that your EOA is upgraded to a contract wallet (proxy) and delegates to the correct implementation.
  - Ensure the proxy's storage is initialized (recipient, relayer, owner).
- **If `setRecipient` or `setRelayer` reverts:**
  - The proxy storage may not be initialized. Call these functions after the upgrade.
- **Always interact with the proxy (unified address), not the implementation.**



## Configuration

Set these environment variables in `.env`:

```env
PRIVATE_KEY=your_private_key         # EOA to be upgraded (unified deposit address)
RECIPIENT_ADDRESS=0x...              # Where relayed funds go
RELAYER_ADDRESS=0x...                # Whitelisted relayer (can be same as EOA)
SEPOLIA_RPC_URL=...
ARBITRUM_SEPOLIA_RPC_URL=...
ETHERSCAN_API_KEY=your_etherscan_api_key
IMPLEMENTATION_ADDRESS=0x...         # Set for upgrade script
```



## How It Works

1. **Deploy:** Implementation contract is deployed on each chain.
2. **Create EOA:** Generate a single EOA to act as the unified deposit address.
3. **Upgrade:** Use EIP-7702 to upgrade the EOA to a smart contract on each chain, delegating to the implementation contract.
4. **Monitor:** Backend watches for USDC/ETH sent to the unified address.
5. **Relay:** Backend relayer triggers forwarding to the recipient.


## Project Progress & EIP-7702 Upgrade Status

### Implementation & Deployment
- Implementation contract deployed and verified on:
  - **Sepolia:** `0xB84903069dA934E91190d3d9E1EfcE19937d1FB7`
  - **Arbitrum Sepolia:** `0xB84903069dA934E91190d3d9E1EfcE19937d1FB7`
- Unified deposit EOA generated and funded on both testnets.

### EIP-7702 Upgrade Preparation
- Used `script/eip7702-upgrade.ts` (or `.js`) to generate the required authorization signature and submit the EIP-7702 upgrade transaction.
- The upgrade transaction has been **successfully submitted and mined** on both Sepolia and Arbitrum Sepolia.
- The system is now fully upgraded and ready for further steps.


## Deployment & Upgrade Details

- **Implementation Contract Address (Sepolia):** `0xB84903069dA934E91190d3d9E1EfcE19937d1FB7`
- **Implementation Contract Address (Arbitrum Sepolia):** `0xB84903069dA934E91190d3d9E1EfcE19937d1FB7`

- **EIP-7702 Upgrade Transaction Hash (Sepolia):**
  - `0x5a3f66091c96207dc4e38f5ac4f1b846b2efc237bdca9e459fac5af4a289f8a2`
- **EIP-7702 Upgrade Transaction Hash (Arbitrum Sepolia):**
  - `0x44c6393bbdbb4d2081f941336c0ed52e1a96ea2d18ce9ad90bde1b4b23e960b5`


## Viem EIP-7702 Upgrade Progress

- The EIP-7702 upgrade was completed using Viem, following the latest best practices.
- The EOA is now a smart wallet on Sepolia and Arbitrum Sepolia, delegating logic to the implementation contract.
- All future interactions use the new smart wallet functionality.


## Testing

```bash
# Run tests
forge test

# Test on Sepolia
forge script script/Test.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```


## Architecture

```
EOA Wallet → EIP-7702 → Smart Contract → Backend Monitor → Recipient
```


## Security & Best Practices

- **Private Keys:** Never commit private keys to git. Use environment variables.
- **Relayer Whitelisting:** Only trusted addresses should be whitelisted as relayers.
- **API Keys:** Use Etherscan V2 API for all supported chains.
- **Separation of Concerns:** For production, consider using separate addresses for deployer, EOA, and relayer.


## Future Directions

- **Full EIP-7702 Integration:** As soon as public tooling supports type `0x04` transactions, the upgrade will be fully automated.
- **Mainnet Deployment:** Ready for mainnet as soon as EIP-7702 is live.
- **More Chains:** Easily extendable to any EVM-compatible chain.
- **Advanced Monitoring:** Add alerting, analytics, and more robust backend features.

---

An failed attempt to solve the Unified Deposit Address problem. 
