// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

/**
 * @title SetupEIP7702
 * @notice Script to upgrade an EOA to a smart contract using EIP-7702
 *         - Derives EOA address from PRIVATE_KEY
 *         - Uses IMPLEMENTATION_ADDRESS and CHAIN_ID from env
 *         - Prints all important info for user
 */
contract SetupEIP7702 is Script {
    function run() external {
        // Load environment variables
        uint256 eoaPrivateKey = vm.envUint("PRIVATE_KEY");
        address implementationAddress = vm.envAddress("IMPLEMENTATION_ADDRESS");
        uint256 chainId = vm.envUint("CHAIN_ID");

        // Derive EOA address from private key
        address eoaAddress = vm.addr(eoaPrivateKey);

        // Print info for user
        console.log("=== EIP-7702 Upgrade ===");
        console.log("EOA Address (Unified Address):", eoaAddress);
        console.log("Implementation Address:", implementationAddress);
        console.log("Chain ID:", chainId);

        // Get current nonce
        uint256 nonce = vm.getNonce(eoaAddress);
        console.log("Current Nonce:", nonce);

        // Create authorization message (example, adjust for EIP-7702 specifics)
        bytes32 messageHash = keccak256(abi.encodePacked(chainId, implementationAddress, nonce));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(eoaPrivateKey, messageHash);

        // Print signature
        console.log("Signature V:", v);
        console.log("Signature R:", vm.toString(r));
        console.log("Signature S:", vm.toString(s));

        // Here you would construct and send the EIP-7702 set code transaction
        // (This part depends on the final EIP-7702 implementation and Foundry support)

        // For now, just print what would be sent
        console.log("Ready to submit EIP-7702 set code transaction for upgrade.");

        string memory json = string(
            abi.encodePacked(
                '{"eoaAddress":"', vm.toString(eoaAddress),
                '","implementationAddress":"', vm.toString(implementationAddress),
                '","chainId":', vm.toString(chainId),
                ',"nonce":', vm.toString(nonce),
                ',"v":', vm.toString(uint256(v)),
                ',"r":"', vm.toString(r),
                '","s":"', vm.toString(s),
                '"}'
            )
        );
        console.log(json);
    }
} 