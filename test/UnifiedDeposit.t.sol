// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UnifiedDeposit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock USDC token for testing
contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        _mint(msg.sender, 1000000 * 10**6); // 1M USDC
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

contract UnifiedDepositTest is Test {
    UnifiedDeposit public deposit;
    MockUSDC public usdc;
    
    address public owner = address(1);
    address public recipient = address(2);
    address public relayer = address(3);
    address public user = address(4);

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock USDC
        usdc = new MockUSDC();
        
        // Deploy unified deposit contract
        deposit = new UnifiedDeposit(recipient, owner);
        
        // Whitelist relayer
        deposit.setRelayer(relayer, true);
        
        vm.stopPrank();
    }

    function testConstructor() public {
        assertEq(deposit.recipient(), recipient);
        assertEq(deposit.owner(), owner);
        assertTrue(deposit.whitelistedRelayers(relayer));
    }

    function testReceiveETH() public {
        vm.deal(user, 1 ether);
        
        vm.prank(user);
        (bool success,) = address(deposit).call{value: 0.5 ether}("");
        assertTrue(success);
        
        assertEq(address(deposit).balance, 0.5 ether);
    }

    function testRelayETH() public {
        // Send ETH to contract
        vm.deal(user, 1 ether);
        vm.prank(user);
        (bool success,) = address(deposit).call{value: 0.5 ether}("");
        assertTrue(success);
        
        // Relay ETH
        vm.prank(relayer);
        deposit.relayETH();
        
        assertEq(address(deposit).balance, 0);
        assertEq(recipient.balance, 0.5 ether);
    }

    function testRelayToken() public {
        // Transfer USDC to contract
        vm.prank(owner);
        usdc.transfer(address(deposit), 1000 * 10**6); // 1000 USDC
        
        // Relay USDC
        vm.prank(relayer);
        deposit.relayToken(address(usdc), 500 * 10**6); // 500 USDC
        
        assertEq(usdc.balanceOf(address(deposit)), 500 * 10**6);
        assertEq(usdc.balanceOf(recipient), 500 * 10**6);
    }

    function testNotWhitelistedRelayer() public {
        vm.prank(user);
        vm.expectRevert(UnifiedDeposit.NotWhitelistedRelayer.selector);
        deposit.relayETH();
    }

    function testSetRelayer() public {
        vm.prank(owner);
        deposit.setRelayer(user, true);
        assertTrue(deposit.whitelistedRelayers(user));
        
        vm.prank(owner);
        deposit.setRelayer(user, false);
        assertFalse(deposit.whitelistedRelayers(user));
    }

    function testSetRecipient() public {
        address newRecipient = address(5);
        
        vm.prank(owner);
        deposit.setRecipient(newRecipient);
        assertEq(deposit.recipient(), newRecipient);
    }

    function testOnlyOwnerFunctions() public {
        vm.prank(user);
        vm.expectRevert();
        deposit.setRelayer(address(6), true);
        
        vm.prank(user);
        vm.expectRevert();
        deposit.setRecipient(address(7));
    }
} 