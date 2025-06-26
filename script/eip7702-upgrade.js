// eip7702-upgrade.ts
import 'dotenv/config'
import { createWalletClient, http, encodeFunctionData, createPublicClient, getContract } from 'viem'
import { sepolia } from 'viem/chains'
import { privateKeyToAccount } from 'viem/accounts'

// === CONFIG ===
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const RECIPIENT_ADDRESS = process.env.RECIPIENT_ADDRESS;

if (!PRIVATE_KEY || !SEPOLIA_RPC_URL || !CONTRACT_ADDRESS || !RECIPIENT_ADDRESS) {
  throw new Error('Missing env vars: PRIVATE_KEY, SEPOLIA_RPC_URL, CONTRACT_ADDRESS, RECIPIENT_ADDRESS')
}

// === CONTRACT ABI ===
const abi = [
  {
    type: 'function',
    name: 'owner',
    inputs: [],
    outputs: [{ name: '', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'setRecipient',
    inputs: [{ name: 'newRecipient', type: 'address' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setRelayer',
    inputs: [
      { name: 'relayer', type: 'address' },
      { name: 'status', type: 'bool' }
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'relayETH',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
] 

// === INIT WALLET ===
const eoa = privateKeyToAccount(PRIVATE_KEY)
const walletClient = createWalletClient({
  account: eoa,
  chain: sepolia,
  transport: http(SEPOLIA_RPC_URL),
})

async function main() {
  console.log('=== EIP-7702 relayETH Call ===')
  console.log('EOA:', eoa.address)
  console.log('Delegated Contract:', CONTRACT_ADDRESS)

  // 0️⃣ Check owner
  const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(SEPOLIA_RPC_URL),
  })
  const owner = await publicClient.readContract({
    address: CONTRACT_ADDRESS,
    abi,
    functionName: 'owner',
  });
  if (owner.toLowerCase() !== eoa.address.toLowerCase()) {
    throw new Error(`EOA is not the owner. Contract owner is: ${owner}`)
  }
  console.log('Owner check passed.')

  // 1️⃣ Encode call to setRecipient
  const setRecipientData = encodeFunctionData({
    abi,
    functionName: 'setRecipient',
    args: [RECIPIENT_ADDRESS],
  })
  const setRecipientAuth = await walletClient.signAuthorization({
    account: eoa,
    contractAddress: CONTRACT_ADDRESS,
    executor: 'self',
  })
  const setRecipientTx = await walletClient.sendTransaction({
    to: eoa.address,
    data: setRecipientData,
    authorizationList: [setRecipientAuth],
  })
  console.log('✅ setRecipient tx submitted:')
  console.log('https://sepolia.etherscan.io/tx/' + setRecipientTx)
  await new Promise((resolve) => setTimeout(resolve, 15000))

  // 2️⃣ Encode call to setRelayer(address,bool)
  const setRelayerData = encodeFunctionData({
    abi,
    functionName: 'setRelayer',
    args: [eoa.address, true],
  })

  // 3️⃣ Sign EIP-7702 Authorization for setRelayer
  const setRelayerAuth = await walletClient.signAuthorization({
    account: eoa,
    contractAddress: CONTRACT_ADDRESS,
    executor: 'self',
  })

  // 4️⃣ Send EIP-7702 Transaction to whitelist EOA as relayer
  const setRelayerTx = await walletClient.sendTransaction({
    to: eoa.address,
    data: setRelayerData,
    authorizationList: [setRelayerAuth],
  })
  console.log('✅ setRelayer tx submitted:')
  console.log('https://sepolia.etherscan.io/tx/' + setRelayerTx)
  await new Promise((resolve) => setTimeout(resolve, 15000))

  // 5️⃣ Encode call to relayETH()
  const data = encodeFunctionData({
    abi,
    functionName: 'relayETH',
  })

  // 6️⃣ Sign EIP-7702 Authorization (self-executing mode)
  const authorization = await walletClient.signAuthorization({
    account: eoa,
    contractAddress: CONTRACT_ADDRESS,
    executor: 'self',
  })

  // 7️⃣ Send EIP-7702 Transaction from EOA
  const txHash = await walletClient.sendTransaction({
    to: eoa.address, // The EOA is executing the contract logic
    data,
    authorizationList: [authorization],
  })

  console.log('✅ relayETH tx submitted:')
  console.log('https://sepolia.etherscan.io/tx/' + txHash)
}

main().catch((err) => {
  console.error('\n❌ Error occurred during transaction:')
  console.error(err)
})
