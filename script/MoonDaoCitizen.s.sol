// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
// import "../src/tables/MoonDaoTableland.sol";
import "../src/ERC5643Citizen.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MoonDaoCitizenTableland citizenTable  = new MoonDaoCitizenTableland("CITIZENTABLE");

        // MoonDAOCitizen citizen = new MoonDAOCitizen("MoonDaoCitizen", "MDC", 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, address(citizenTable));

        vm.stopBroadcast();
    }
}
