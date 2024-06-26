pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/tables/JobBoardTable.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        JobBoardTable jobBoardTable = new JobBoardTable("JOBBOARD");
        jobBoardTable.setMoonDaoTeam(0x9D78fc5aD4a485Dc6A8159509A6ca476146A59a2);

        vm.stopBroadcast();
    }
}