// SPDX-License-Identifier: BSL 1.1
pragma solidity ^0.8.15;
import "forge-std/Script.sol";
import {Create2Deployer} from "scripts/DeployScripts.s.sol";
import {SettlementGateway} from "contracts/standard-bridge/SettlementGateway.sol";
import {L1Gateway} from "contracts/standard-bridge/L1Gateway.sol";

contract DeploySettlementGateway is Script, Create2Deployer {
    function run() external {

        // Note this addr is dependant on values given to contract constructor
        address expectedAddr = 0xF457d6dC28418182AFfc4A0790f3A9151Cf0499f;
        if (isContractDeployed(expectedAddr)) {
            console.log("Standard bridge gateway on settlement chain already deployed to:",
                expectedAddr);
            return;
        }

        vm.startBroadcast();

        checkCreate2Deployed();
        checkDeployer();

        // Forge deploy with salt uses create2 proxy from https://github.com/primevprotocol/deterministic-deployment-proxy
        bytes32 salt = 0x8989000000000000000000000000000000000000000000000000000000000000;

        address whitelistAddr = 0x57508f0B0f3426758F1f3D63ad4935a7c9383620;
        address relayerAddr = vm.envAddress("RELAYER_ADDR");

        SettlementGateway gateway = new SettlementGateway{salt: salt}(
            whitelistAddr,
            msg.sender, // Owner
            relayerAddr,
            1, 1); // Fees set to 1 wei for now
        console.log("Standard bridge gateway for settlement chain deployed to:",
            address(gateway));

        vm.stopBroadcast();
    }
}

contract DeployL1Gateway is Script, Create2Deployer {
    function run() external {

        // Note this addr is dependant on values given to contract constructor
        address expectedAddr = 0xE3e28fFC8A90EE85db78815D22b33CbEe7E64A1d;
        if (isContractDeployed(expectedAddr)) {
            console.log("Standard bridge gateway on l1 already deployed to:",
                expectedAddr);
            return;
        }

        vm.startBroadcast();

        checkCreate2Deployed();
        checkDeployer();

        // Forge deploy with salt uses create2 proxy from https://github.com/primevprotocol/deterministic-deployment-proxy
        bytes32 salt = 0x8989000000000000000000000000000000000000000000000000000000000000;

        address relayerAddr = vm.envAddress("RELAYER_ADDR");

        L1Gateway gateway = new L1Gateway{salt: salt}(
            msg.sender, // Owner
            relayerAddr,
            1, 1); // Fees set to 1 wei for now
        console.log("Standard bridge gateway for l1 deployed to:",
            address(gateway));

        vm.stopBroadcast();
    }
}
