// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPreConfCommitmentStore
 * @dev Interface for PreConfCommitmentStore
 */
interface IPreConfCommitmentStore {
    // Structs, events, and errors can also be included in the interface if they are used in the external functions

    struct PreConfCommitment {
        bool commitmentUsed;
        address bidder;
        address commiter;
        uint64 bid;
        uint64 blockNumber;
        bytes32 bidHash;
        string txnHash;
        string commitmentHash;
        bytes bidSignature;
        bytes commitmentSignature;
    }

    event SignatureVerified(
        address indexed signer,
        string txnHash,
        uint64 indexed bid,
        uint64 blockNumber
    );

    // External functions that need to be implemented

    function getBidHash(
        string memory _txnHash,
        uint64 _bid,
        uint64 _blockNumber
    ) external view returns (bytes32);

    function getPreConfHash(
        string memory _txnHash,
        uint64 _bid,
        uint64 _blockNumber,
        bytes32 _bidHash,
        string memory _bidSignature
    ) external view returns (bytes32);

    function retreiveCommitments() external view returns (PreConfCommitment[] memory);

    function retreiveCommitment() external view returns (PreConfCommitment memory);

    function verifyBid(
        uint64 bid,
        uint64 blockNumber,
        string memory txnHash,
        bytes calldata bidSignature
    ) external view returns (bytes32 messageDigest, address recoveredAddress, uint256 stake);

    function storeCommitment(
        uint64 bid,
        uint64 blockNumber,
        string memory txnHash,
        string memory commitmentHash,
        bytes calldata bidSignature,
        bytes memory commitmentSignature
    ) external returns (uint256);

    function getCommitment(bytes32 commitmentHash) external view returns (PreConfCommitment memory);

    function initiateSlash(bytes32 commitmentHash) external;

    function initateReward(bytes32 commitmentHash) external;

    function updateOracle(address newOracle) external;

    function updateProviderRegistry(address newProviderRegistry) external;

    function updateUserRegistry(address newUserRegistry) external;

    // Public functions that can be included if they are meant to be called from other contracts

    function _bytes32ToHexString(bytes32 _bytes32) external pure returns (string memory);

    function _bytesToHexString(bytes memory _bytes) external pure returns (string memory);
}
