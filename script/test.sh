#!/bin/bash

# Simple test script for Unified Deposit
# Usage: ./script/test.sh [network]

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

echo "Testing on $NETWORK..."

case $NETWORK in
    "sepolia")
        RPC_URL=$SEPOLIA_RPC_URL
        ;;
    "arbitrum")
        RPC_URL=$ARBITRUM_SEPOLIA_RPC_URL
        ;;
    *)
        echo "Unknown network: $NETWORK"
        echo "Supported networks: sepolia, arbitrum"
        exit 1
        ;;
esac

# Check if contract address is set
if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "Error: CONTRACT_ADDRESS not set in .env"
    echo "Please set it to the deployed contract address"
    exit 1
fi

echo "Running tests on $NETWORK..."
echo "Contract Address: $CONTRACT_ADDRESS"

# Run Foundry tests
echo "Running Foundry tests..."
forge test

# Test contract on network
echo "Testing contract on $NETWORK..."
forge script script/Test.s.sol \
    --rpc-url "$RPC_URL" \
    --broadcast

echo "Tests completed!" 