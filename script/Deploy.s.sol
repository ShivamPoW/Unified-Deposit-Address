// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UnifiedDeposit.sol";

/**
 * @title DeployScript
 * @notice Deployment script for UnifiedDeposit contract
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        address relayer = vm.envAddress("RELAYER_ADDRESS");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the contract with the deployer as owner
        UnifiedDeposit deposit = new UnifiedDeposit(recipient, deployer);
        
        // Whitelist the relayer
        deposit.setRelayer(relayer, true);
        
        vm.stopBroadcast();
        
        console.log("UnifiedDeposit deployed at:", address(deposit));
        console.log("Recipient:", recipient);
        console.log("Relayer whitelisted:", relayer);
    }
} 