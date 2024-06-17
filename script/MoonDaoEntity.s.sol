// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MoonDaoEntityTableland} from "../src/tables/MoonDaoEntityTableland.sol";
// import "../src/ERC5643.sol";
import {MoonDAOEntityCreator} from "../src/MoonDAOEntityCreator.sol";
import {IHats} from "@hats/Interfaces/IHats.sol";
import {MoonDAOEntity} from "../src/ERC5643.sol";
import {Whitelist} from "../src/Whitelist.sol";



contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Whitelist whitelist = new Whitelist();

        IHats hats = IHats(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);

        // uint256 topHatId = hats.mintTopHat(msg.sender, "", "");

        uint256 moonDaoEntityEdminHatId = hats.createHat(8384543413483848976141441692063105139501151915410118041623222787506176, "", 1, 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, true, "");

        MoonDAOEntity entity = new MoonDAOEntity("MoonDaoEntity", "MDE", 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);

        MoonDaoEntityTableland entityTable  = new MoonDaoEntityTableland("ENTITYTABLE");

        entityTable.setMoonDaoEntity(address(entity));

        MoonDAOEntityCreator creator = new MoonDAOEntityCreator(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137, address(entity), 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA, 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC, address(entityTable), address(whitelist));

        creator.setOpenAccess(true);

        creator.setMoonDaoEntityEdminHatId(moonDaoEntityEdminHatId);

        hats.mintHat(moonDaoEntityEdminHatId, address(creator));
        hats.changeHatEligibility(moonDaoEntityEdminHatId, address(creator));

        vm.stopBroadcast();
    }
}
