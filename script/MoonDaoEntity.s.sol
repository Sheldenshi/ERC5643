// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
// import "../src/tables/MoonDaoTableland.sol";
// import "../src/ERC5643.sol";
import "../src/MoonDAOEntityCreator.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MoonDaoEntityTableland entityTable  = new MoonDaoEntityTableland("ENTITYTABLE");

        MoonDAOEntity entity = new MoonDAOEntity("MoonDaoEntity", "MDE", 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);

        MoonDAOEntityCreator creator = new MoonDAOEntityCreator(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137, address(entity), 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA, 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC, address(entityTable));

        vm.stopBroadcast();
    }
}
