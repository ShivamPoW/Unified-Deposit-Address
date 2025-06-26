#!/bin/bash

# Simple deployment script for Unified Deposit
# Usage: ./script/deploy.sh [network]

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Default network
NETWORK=${1:-sepolia}

echo "Deploying to $NETWORK..."

case $NETWORK in
    "sepolia")
        RPC_URL=$SEPOLIA_RPC_URL
        EXPLORER_API_KEY=$ETHERSCAN_API_KEY
        ;;
    "arbitrum")
        RPC_URL=$ARBITRUM_SEPOLIA_RPC_URL
        EXPLORER_API_KEY=$ETHERSCAN_API_KEY
        ;;
    *)
        echo "Unknown network: $NETWORK"
        echo "Supported networks: sepolia, arbitrum"
        exit 1
        ;;
esac

# Check required environment variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$RECIPIENT_ADDRESS" ]; then
    echo "Error: RECIPIENT_ADDRESS not set in .env"
    exit 1
fi

if [ -z "$RELAYER_ADDRESS" ]; then
    echo "Error: RELAYER_ADDRESS not set in .env"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo "Error: RPC_URL not set for network $NETWORK"
    exit 1
fi

echo "Deploying UnifiedDeposit contract..."
echo "Network: $NETWORK"
echo "Recipient: $RECIPIENT_ADDRESS"
echo "Relayer: $RELAYER_ADDRESS"

# Deploy contract
forge script script/Deploy.s.sol \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --verify \
    --etherscan-api-key "$EXPLORER_API_KEY"

echo "Deployment completed!"
echo "Remember to update your backend .env with the deployed contract address" 