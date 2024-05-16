// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC5643.sol";
import "../src/MoonDAOEntityCreator.sol";

contract CreatorTest is Test {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);
    uint256 tokenId = 0;
    uint256 tokenId2 = 1;
    uint256 tokenId3= 2;
    string uri = "https://test.com";
    MoonDAOEntity erc5643;
    MoonDAOEntityCreator creator;

    function setUp() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        erc5643 = new MoonDAOEntity("erc5369", "ERC5643", 0xF69ed83F805c0C271f1A7094d5092Dc0cAFa7008, 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);
        // TODO
        creator = new MoonDAOEntityCreator(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137, address(erc5643), 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA, 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC, 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);
    }

    // function testMint() public {
    //     vm.prank(user1);
    //     creator.createMoonDAOEntity{value: 0.1 ether}(uri, uri);
    // }



}
