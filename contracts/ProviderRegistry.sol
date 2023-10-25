// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Provider Registry
/// @author Kartik Chopra
/// @notice This contract is for provider registry and staking.
contract ProviderRegistry is Ownable, ReentrancyGuard {
    /// @dev Minimum stake required for registration
    uint256 public minStake;

    /// @dev Address of the pre-confirmations contract
    address public preConfirmationsContract;

    /// @dev Mapping from provider address to whether they are registered or not
    mapping(address => bool) public providerRegistered;

    /// @dev Mapping from provider addresses to their staked amount
    mapping(address => uint256) public providerStakes;

    /// @dev Event for provider registration
    event ProviderRegistered(address indexed provider, uint256 stakedAmount);

    /// @dev Event for depositing funds
    event FundsDeposited(address indexed provider, uint256 amount);

    /// @dev Event for slashing funds
    event FundsSlashed(address indexed provider, uint256 amount);

    /// @dev Event for rewarding funds
    event FundsRewarded(address indexed provider, uint256 amount);

    /**
     * @dev Fallback function to revert all calls, ensuring no unintended interactions.
     */
    fallback() external payable {
        revert("Invalid call");
    }

    /**
     * @dev Receive function is disabled for this contract to prevent unintended interactions.
     * Should be removed from here in case the registerAndStake function becomes more complex
     */
    receive() external payable {
        revert("Invalid call");
    }

    /**
     * @dev Constructor to initialize the contract with a minimum stake requirement.
     * @param _minStake The minimum stake required for provider registration.
     */
    constructor(uint256 _minStake) Ownable(msg.sender) {
        minStake = _minStake;
    }

    /**
     * @dev Modifier to restrict a function to only be callable by the pre-confirmations contract.
     */
    modifier onlyPreConfirmationEngine() {
        require(
            msg.sender == preConfirmationsContract,
            "Only the pre-confirmations contract can call this function"
        );
        _;
    }

    /**
     * @dev Sets the pre-confirmations contract address. Can only be called by the owner.
     * @param contractAddress The address of the pre-confirmations contract.
     */
    function setPreconfirmationsContract(
        address contractAddress
    ) external onlyOwner {
        require(
            preConfirmationsContract == address(0),
            "Preconfirmations Contract is already set and cannot be changed."
        );
        preConfirmationsContract = contractAddress;
    }

    /**
     * @dev Register and stake function for providers.
     */
    function registerAndStake() public payable {
        require(!providerRegistered[msg.sender], "Provider already registered");
        require(msg.value >= minStake, "Insufficient stake");

        providerStakes[msg.sender] = msg.value;
        providerRegistered[msg.sender] = true;

        emit ProviderRegistered(msg.sender, msg.value);
    }

    /**
     * @dev Check the stake of a provider.
     * @param provider The address of the provider.
     * @return The staked amount for the provider.
     */
    function checkStake(address provider) external view returns (uint256) {
        return providerStakes[provider];
    }

    /**
     * @dev Deposit more funds into the provider's stake.
     */
    function depositFunds() external payable {
        require(providerRegistered[msg.sender], "Provider not registered");
        providerStakes[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Slash funds from the provider and send the slashed amount to the user.
     * @dev reenterancy not necessary but still putting here for precaution
     * @param amt The amount to slash from the provider's stake.
     * @param provider The address of the provider.
     * @param user The address to transfer the slashed funds to.
     */
    function slash(
        uint256 amt,
        address provider,
        address payable user
    ) external nonReentrant onlyPreConfirmationEngine {
        require(providerStakes[provider] >= amt, "Insufficient funds to slash");
        providerStakes[provider] -= amt;

        (bool success, ) = user.call{value: amt}("");
        require(success, "Couldn't transfer to provider");

        emit FundsSlashed(provider, amt);
    }
}
