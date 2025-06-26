# Unified Deposit Backend

Simple backend service that monitors unified deposit addresses and automatically relays USDC transfers to the recipient.

## Features

- **Multi-chain Monitoring**: Monitors Sepolia and Arbitrum Sepolia networks
- **Automatic Relaying**: Automatically forwards USDC and ETH to recipient
- **Whitelisted Relayer**: Secure permission system
- **REST API**: Health checks and manual relay endpoints
- **Event Monitoring**: Listens for token transfers and contract events

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp env.example .env
# Edit .env with your values
```

### 3. Start Service

```bash
npm start
```

## Configuration

Set these environment variables in `.env`:

```bash
# Service Configuration
BACKEND_PORT=3000

# Relayer Configuration
RELAYER_PRIVATE_KEY=your_relayer_private_key
UNIFIED_ADDRESS=0x... # Deployed contract address

# Network RPC URLs
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
```

## API Endpoints

### Health Check
```
GET /health
```
Returns service status and monitored networks.

### Contract Info
```
GET /contract/:network
```
Returns contract information for a specific network.

### Manual Relay
```
POST /relay/:network
Body: { "token": "0x...", "amount": "1000000" }
```
Manually trigger a token relay.

## How It Works

1. **Event Monitoring**: Listens for `TokenReceived` events from the contract
2. **USDC Detection**: Monitors USDC transfer events to the unified address
3. **Automatic Relaying**: Calls `relayToken()` or `relayETH()` functions
4. **Transaction Confirmation**: Waits for relay transactions to confirm

## Supported Networks

- **Sepolia** (Chain ID: 11155111)
- **Arbitrum Sepolia** (Chain ID: 421614)

## USDC Addresses

- Sepolia: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`
- Arbitrum Sepolia: `0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d`

## Security

- Only whitelisted relayers can call relay functions
- Private keys should be kept secure
- Use environment variables for sensitive data 