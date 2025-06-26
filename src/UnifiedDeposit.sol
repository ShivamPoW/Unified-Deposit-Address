// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title UnifiedDeposit
 * @notice Simple contract for unified deposit address with whitelisted relayer
 * @dev This contract will be used as implementation for EIP-7702 upgraded EOAs
 */
contract UnifiedDeposit is Ownable {
    using SafeERC20 for IERC20;

    // State variables
    address public recipient;
    mapping(address => bool) public whitelistedRelayers;
    
    // Events
    event TokenReceived(address indexed token, address indexed from, uint256 amount);
    event TokenRelayed(address indexed token, address indexed to, uint256 amount, address indexed relayer);
    event RelayerWhitelisted(address indexed relayer, bool status);
    event RecipientUpdated(address indexed oldRecipient, address indexed newRecipient);

    // Errors
    error NotWhitelistedRelayer();
    error ZeroAmount();
    error InvalidAddress();
    error InsufficientBalance();

    /**
     * @notice Constructor
     * @param _recipient Address to receive relayed tokens
     * @param _owner Owner of the contract
     */
    constructor(address _recipient, address _owner) Ownable(_owner) {
        if (_recipient == address(0)) revert InvalidAddress();
        recipient = _recipient;
    }

    /**
     * @notice Receive ETH
     */
    receive() external payable {
        if (msg.value > 0) {
            emit TokenReceived(address(0), msg.sender, msg.value);
        }
    }

    /**
     * @notice Relay tokens to recipient
     * @param token Token address to relay
     * @param amount Amount to relay
     */
    function relayToken(address token, uint256 amount) external {
        if (!whitelistedRelayers[msg.sender]) revert NotWhitelistedRelayer();
        if (amount == 0) revert ZeroAmount();
        if (token == address(0)) revert InvalidAddress();

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < amount) revert InsufficientBalance();

        IERC20(token).safeTransfer(recipient, amount);
        emit TokenRelayed(token, recipient, amount, msg.sender);
    }

    /**
     * @notice Relay ETH to recipient
     */
    function relayETH() external {
        if (!whitelistedRelayers[msg.sender]) revert NotWhitelistedRelayer();
        
        uint256 balance = address(this).balance;
        if (balance == 0) revert ZeroAmount();

        (bool success, ) = payable(recipient).call{value: balance}("");
        require(success, "ETH transfer failed");
        
        emit TokenRelayed(address(0), recipient, balance, msg.sender);
    }

    /**
     * @notice Add/remove relayer from whitelist
     * @param relayer Address to whitelist
     * @param status True to add, false to remove
     */
    function setRelayer(address relayer, bool status) external onlyOwner {
        if (relayer == address(0)) revert InvalidAddress();
        whitelistedRelayers[relayer] = status;
        emit RelayerWhitelisted(relayer, status);
    }

    /**
     * @notice Update recipient address
     * @param newRecipient New recipient address
     */
    function setRecipient(address newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert InvalidAddress();
        address oldRecipient = recipient;
        recipient = newRecipient;
        emit RecipientUpdated(oldRecipient, newRecipient);
    }
} 