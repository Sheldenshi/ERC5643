// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC5643.sol";
import "../src/moonDao/EntityERC5643.sol";

contract ERC5643Test is Test {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);
    uint256 tokenId = 0;
    uint256 tokenId2 = 1;
    uint256 tokenId3= 2;
    string uri = "https://test.com";
    MoonDaoEntityERC5643 erc5643;

    function setUp() public {
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);

        erc5643 = new MoonDaoEntityERC5643("erc5369", "ERC5643");
        uint256 token1 = erc5643.mint(user1, uri);
        assertEq(token1, tokenId);
    }

    function testRenewalInvalidTokenId() public {
        vm.prank(user1);
        vm.expectRevert(InvalidTokenId.selector);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId + 10, 30 days);
    }

    function testRenewalNotOwner() public {
        // vm.expectRevert(CallerNotOwnerNorApproved.selector);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId, 2000);
    }

    function testRenewalDurationTooShort() public {
        erc5643.setMinimumRenewalDuration(1000);
        vm.prank(user1);
        vm.expectRevert(RenewalTooShort.selector);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId, 999);
    }

    function testRenewalDurationTooLong() public {
        erc5643.setMaximumRenewalDuration(1000);
        vm.prank(user1);
        vm.expectRevert(RenewalTooLong.selector);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId, 1001);
    }

    function testRenewalInsufficientPayment() public {
        vm.prank(user1);
        vm.expectRevert(InsufficientPayment.selector);
        erc5643.renewSubscription{value: 0.09 ether}(tokenId, 30 days);
    }

    function testRenewalExistingSubscription() public {
        vm.warp(1000);
        vm.prank(user1);
        // console.logBool(erc5643.isRenewable(tokenId));
        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId, 30 days + 1000);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId, 30 days);
        assertEq(user1.balance, 0.9 ether);
    }

    function testRenewalNewSubscription() public {
        vm.warp(1000);
        vm.prank(user2);
        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId2, 60 days + 1000);
        erc5643.mintWithSubscription{value: 0.2 ether}(user2, 60 days, uri);

        // This renewal will succeed because the subscription is renewable
        vm.prank(user2);
        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId2, 90 days + 1000);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId2, 30 days);
    }

    function testCancelValid() public {
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId, 0);
        erc5643.cancelSubscription(tokenId);
    }

    function testCancelNotOwner() public {
        vm.expectRevert(CallerNotOwnerNorApproved.selector);
        erc5643.cancelSubscription(tokenId);
    }

    function testExpiresAt() public {
        vm.warp(1000);

        assertEq(erc5643.expiresAt(tokenId), 0);
        vm.startPrank(user1);
        erc5643.renewSubscription{value: 0.1 ether}(tokenId, 2000);
        assertEq(erc5643.expiresAt(tokenId), 3000);

        erc5643.cancelSubscription(tokenId);
        assertEq(erc5643.expiresAt(tokenId), 0);
    }

    function testExpiresAtInvalidToken() public {
        vm.expectRevert(InvalidTokenId.selector);
        erc5643.expiresAt(tokenId2 + 10);
    }

    function testIsRenewableInvalidToken() public {
        vm.expectRevert(InvalidTokenId.selector);
        erc5643.isRenewable(tokenId2 + 10);
    }

    function testExtendSubscriptionInvalidToken() public {
        vm.expectRevert(InvalidTokenId.selector);
        erc5643.extendSubscription(tokenId + 100, 30 days);
    }

    function testRenewalDiscount() public {
        vm.warp(1000);
        vm.startPrank(user2);

        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId2, 60 days + 1000);
        uint256 id = erc5643.mintWithSubscription{value: 0.2 ether}(user2, 60 days, uri);
        assertEq(erc5643.expiresAt(tokenId2), 60 days + 1000);

        vm.deal(user2, 1 ether);
        // without discount it's 1.2 eth
        vm.expectEmit(true, true, false, true);
        emit SubscriptionUpdate(tokenId2, 365 days + 60 days + 1000);
        erc5643.renewSubscription{value: 1 ether}(tokenId2, 365 days);
        
    }

    function testTransfer() public {
        vm.prank(user1);
        vm.expectRevert("You may not transfer your token!");
        erc5643.transferFrom(user1, user2, 0);
    }

    function testURI() public {
        string memory tokenURI = erc5643.tokenURI(tokenId);
        assertEq(tokenURI, uri);
    }

    function testContractOnwerUpdateURI() public {
        erc5643.setTokenURI(tokenId, "https://reandom.com");
        string memory tokenURI = erc5643.tokenURI(tokenId);
        assertEq(tokenURI, "https://reandom.com");
    }

    function testTokenOnwerUpdateURI() public {
        vm.prank(user1);
        erc5643.setTokenURI(tokenId, "https://reandom.com");
        string memory tokenURI = erc5643.tokenURI(tokenId);
        assertEq(tokenURI, "https://reandom.com");
    }

    function testNotTokenOwnerUpdateURI() public {
        vm.prank(user2);
        vm.expectRevert("Only token owner or contract owner can set URI");
        erc5643.setTokenURI(tokenId, "https://reandom.com");
    }
}
