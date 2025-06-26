const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');
const express = require('express');
const cors = require('cors');
require('dotenv').config();

// === CONFIG ===
const UNIFIED_ADDRESS = process.env.UNIFIED_ADDRESS;
const RELAYER_PRIVATE_KEY = process.env.RELAYER_PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const ARBITRUM_SEPOLIA_RPC_URL = process.env.ARBITRUM_SEPOLIA_RPC_URL;
const BACKEND_PORT = process.env.BACKEND_PORT || 3000;

const USDC_ADDRESSES = {
  11155111: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238', // Sepolia
  421614: '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d'    // Arbitrum Sepolia
};

// === ABI (inline, minimal) ===
const ABI = [
  {
    "inputs": [],
    "name": "recipient",
    "outputs": [
      { "internalType": "address", "name": "", "type": "address" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "", "type": "address" }
    ],
    "name": "whitelistedRelayers",
    "outputs": [
      { "internalType": "bool", "name": "", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "token", "type": "address" },
      { "internalType": "uint256", "name": "amount", "type": "uint256" }
    ],
    "name": "relayToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

const chains = [
  {
    name: 'sepolia',
    rpcUrl: SEPOLIA_RPC_URL,
    chainId: 11155111,
    usdc: USDC_ADDRESSES[11155111]
  },
  {
    name: 'arbitrum',
    rpcUrl: ARBITRUM_SEPOLIA_RPC_URL,
    chainId: 421614,
    usdc: USDC_ADDRESSES[421614]
  }
];

function getProviderAndContract(rpcUrl, relayerKey, contractAddress, abi) {
  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(relayerKey, provider);
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  return { provider, wallet, contract };
}

async function monitorChain({ name, rpcUrl, chainId, usdc }) {
  const { provider, wallet, contract } = getProviderAndContract(rpcUrl, RELAYER_PRIVATE_KEY, UNIFIED_ADDRESS, ABI);
  console.log(`[${name}] Monitoring USDC transfers to ${UNIFIED_ADDRESS}...`);

  // Defensive: Try to read recipient
  try {
    const recipient = await contract.recipient();
    console.log(`[${name}] Current recipient: ${recipient}`);
  } catch (err) {
    console.warn(`[${name}] Could not read recipient():`, err.message || err);
  }

  // USDC Transfer event signature
  const transferTopic = ethers.id('Transfer(address,address,uint256)');
  const filter = {
    address: usdc,
    topics: [
      transferTopic,
      null,
      ethers.zeroPadValue(UNIFIED_ADDRESS, 32)
    ]
  };

  provider.on(filter, async (log) => {
    try {
      // Parse event
      const iface = new ethers.Interface([
        'event Transfer(address indexed from, address indexed to, uint256 value)'
      ]);
      const event = iface.parseLog(log);
      const from = event.args[0];
      const to = event.args[1];
      const amount = event.args[2];
      console.log(`[${name}] USDC received: from ${from} to ${to}, amount ${amount}`);

      // Check relayer is whitelisted
      let isWhitelisted = false;
      try {
        isWhitelisted = await contract.whitelistedRelayers(wallet.address);
      } catch (err) {
        console.error(`[${name}] Error checking whitelistedRelayers:`, err.message || err);
        return;
      }
      if (!isWhitelisted) {
        console.error(`[${name}] Relayer is not whitelisted!`);
        return;
      }

      // Relay the USDC to the recipient
      try {
        const tx = await contract.relayToken(usdc, amount);
        console.log(`[${name}] relayToken tx sent: ${tx.hash}`);
        const receipt = await tx.wait();
        console.log(`[${name}] relayToken confirmed: ${receipt.transactionHash}`);
      } catch (err) {
        console.error(`[${name}] relayToken failed:`, err.message || err);
      }
    } catch (err) {
      console.error(`[${name}] Error handling USDC transfer:`, err.message || err);
    }
  });
}

for (const chainConfig of chains) {
  if (chainConfig.rpcUrl && UNIFIED_ADDRESS && RELAYER_PRIVATE_KEY) {
    monitorChain(chainConfig).catch(console.error);
  }
}

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    monitoredChains: chains.filter(c => c.rpcUrl).map(c => c.name)
  });
});

app.listen(BACKEND_PORT, () => {
  console.log(`Unified Deposit Backend (ethers.js) running on port ${BACKEND_PORT}`);
}); 