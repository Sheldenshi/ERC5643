pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/tables/MarketplaceTable.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MarketplaceTable marketplace = new MarketplaceTable("MARKETPLACE");
        // jobBoardTable.setMoonDaoEntity(0x241A6e3c7341A994E6c0ff9F043AC78041352E64);

        vm.stopBroadcast();
    }
}