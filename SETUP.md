# Setup Guide - Unified Deposit Address

Complete setup guide for the unified deposit address system.

## Prerequisites

1. **Foundry** - Install from https://getfoundry.sh/
2. **Node.js 18+** - Install from https://nodejs.org/
3. **Git** - For version control

## Step 1: Project Setup

```bash
# Navigate to Simple directory
cd Simple

# Install Foundry dependencies
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std

# Install backend dependencies
cd backend
npm install
cd ..
```

## Step 2: Environment Configuration

### Main Environment (.env)
```bash
# Copy example file
cp env.example .env

# Edit with your values
nano .env
```

Required variables:
- `PRIVATE_KEY` - Your deployment private key
- `RECIPIENT_ADDRESS` - Address to receive relayed tokens
- `RELAYER_ADDRESS` - Address that will act as relayer
- `SEPOLIA_RPC_URL` - Sepolia RPC endpoint
- `ARBITRUM_SEPOLIA_RPC_URL` - Arbitrum Sepolia RPC endpoint
- `ETHERSCAN_API_KEY` - For contract verification
- `ARBISCAN_API_KEY` - For contract verification

### Backend Environment (backend/.env)
```bash
cd backend
cp env.example .env
nano .env
```

Required variables:
- `RELAYER_PRIVATE_KEY` - Private key for the relayer
- `UNIFIED_ADDRESS` - Deployed contract address (set after deployment)
- `SEPOLIA_RPC_URL` - Sepolia RPC endpoint
- `ARBITRUM_SEPOLIA_RPC_URL` - Arbitrum Sepolia RPC endpoint

## Step 3: Contract Deployment

### Deploy to Sepolia
```bash
./script/deploy.sh sepolia
```

### Deploy to Arbitrum Sepolia
```bash
./script/deploy.sh arbitrum
```

### Verify Deployment
After deployment, note the contract addresses and update:
1. `backend/.env` with `UNIFIED_ADDRESS`
2. Main `.env` with `CONTRACT_ADDRESS` for testing

## Step 4: EIP-7702 Setup

**Note**: EIP-7702 is still in development. The current implementation shows the structure but requires:

1. **Create EOA**: Generate a new EOA wallet
2. **Sign Authorization**: EOA owner signs authorization for implementation contract
3. **Submit Set Code Transaction**: Submit type 0x04 transaction with authorization

```bash
# This is a placeholder - actual EIP-7702 implementation pending
forge script script/SetupEIP7702.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## Step 5: Backend Service

### Start Backend
```bash
cd backend
npm start
```

### Verify Backend
```bash
# Health check
curl http://localhost:3000/health

# Contract info
curl http://localhost:3000/contract/sepolia
```

## Step 6: Testing

### Run Tests
```bash
# Local tests
forge test

# Network tests
./script/test.sh sepolia
./script/test.sh arbitrum
```

### Manual Testing
1. Send USDC to the unified address on any chain
2. Backend should automatically relay to recipient
3. Check recipient balance

## Step 7: Monitoring

### Backend Logs
```bash
cd backend
npm start
```

### API Endpoints
- `GET /health` - Service status
- `GET /contract/:network` - Contract information
- `POST /relay/:network` - Manual relay trigger

## Troubleshooting

### Common Issues

1. **Contract not deployed**
   - Check RPC URLs and API keys
   - Verify private key has sufficient funds

2. **Backend not connecting**
   - Check RPC URLs
   - Verify contract address is correct
   - Ensure relayer is whitelisted

3. **Relay not working**
   - Check relayer private key
   - Verify relayer is whitelisted
   - Check recipient address

### Debug Commands

```bash
# Check contract state
forge script script/Test.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast

# Check backend logs
cd backend && npm start

# Test API endpoints
curl http://localhost:3000/health
```

## Security Notes

1. **Private Keys**: Never commit private keys to git
2. **Environment Files**: Keep .env files secure
3. **Relayer Security**: Only whitelist trusted relayers
4. **Network Security**: Use secure RPC endpoints

## Next Steps

1. **Production Deployment**: Deploy to mainnet networks
2. **EIP-7702 Integration**: Implement full EIP-7702 functionality
3. **Additional Networks**: Add more blockchain networks
4. **Monitoring**: Add comprehensive monitoring and alerting 