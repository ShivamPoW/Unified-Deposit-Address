// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UnifiedDeposit.sol";

/**
 * @title TestScript
 * @notice Test script to verify contract functionality
 */
contract TestScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        UnifiedDeposit deposit = UnifiedDeposit(payable(contractAddress));
        
        // Test basic functionality
        console.log("Contract Address:", contractAddress);
        console.log("Recipient:", deposit.recipient());
        console.log("Owner:", deposit.owner());
        
        // Test relayer whitelist
        address relayer = vm.envAddress("RELAYER_ADDRESS");
        bool isWhitelisted = deposit.whitelistedRelayers(relayer);
        console.log("Relayer whitelisted:", isWhitelisted);
        
        vm.stopBroadcast();
    }
} 