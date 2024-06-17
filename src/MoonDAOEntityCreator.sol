// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { MoonDAOEntity } from "./ERC5643.sol";
import "@hats/Interfaces/IHats.sol";
import "./IMoonDAOEntityCreator.sol";
import "./GnosisSafeProxyFactory.sol";
import "./GnosisSafeProxy.sol";
import {MoonDaoEntityTableland} from "./tables/MoonDaoEntityTableland.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Whitelist} from "./WhiteList.sol";

contract MoonDAOEntityCreator is Ownable {

    IHats internal hats;

    MoonDAOEntity internal moonDAOEntity;

    address internal gnosisSingleton;

    GnosisSafeProxyFactory internal gnosisSafeProxyFactory;

    MoonDaoEntityTableland public table;

    uint256 public MoonDaoEntityEdminHatId;

    Whitelist internal whitelist;

    bool public openAccess;

    constructor(address _hats, address _moonDAOEntity, address _gnosisSingleton, address _gnosisSafeProxyFactory, address _table, address _whitelist) Ownable(msg.sender) {
        hats = IHats(_hats);
        moonDAOEntity = MoonDAOEntity(_moonDAOEntity);
        gnosisSingleton = _gnosisSingleton;
        gnosisSafeProxyFactory = GnosisSafeProxyFactory(_gnosisSafeProxyFactory);
        table = MoonDaoEntityTableland(_table);
        whitelist = Whitelist(_whitelist);
    }

    function setMoonDaoEntityEdminHatId(uint256 _MoonDaoEntityEdminHatId) external onlyOwner() {
        MoonDaoEntityEdminHatId = _MoonDaoEntityEdminHatId;
    }

    function setOpenAccess(bool _openAccess) external onlyOwner() {
        openAccess = _openAccess;
    }

    function createMoonDAOEntity(string memory adminHatURI, string memory managerHatURI, string calldata name, string calldata bio, string calldata image, string calldata twitter, string calldata communications, string calldata website, string calldata _view, string memory formId) external payable returns (uint256 tokenId, uint256 childHatId) {

        require(whitelist.isWhitelisted(msg.sender) || openAccess, "Only whitelisted addresses can create MoonDAOEntity");
        

        bytes memory safeCallData = constructSafeCallData(msg.sender);
        GnosisSafeProxy gnosisSafe = gnosisSafeProxyFactory.createProxy(gnosisSingleton, safeCallData);
        
        //mint hat
        uint256 entityAdminHat = hats.createHat(MoonDaoEntityEdminHatId, adminHatURI, 1, address(gnosisSafe), address(gnosisSafe), true, "");
        hats.mintHat(entityAdminHat, address(this));

        uint256 entityManagerHat = hats.createHat(entityAdminHat, managerHatURI, 8, msg.sender, msg.sender, true, "");

        hats.mintHat(entityManagerHat, msg.sender);

        hats.transferHat(entityAdminHat, address(this), address(gnosisSafe));

        tokenId = moonDAOEntity.mintTo{value: msg.value}(address(gnosisSafe), entityAdminHat, entityManagerHat);

        table.insertIntoTable(tokenId, name, bio, image, twitter, communications, website, _view, formId);
    }

    function constructSafeCallData(address caller) internal returns (bytes memory) {
        bytes memory part1 = hex"b63e800d0000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140000000000000000000000000017062a1de2fe6b99be3d9d37841fed19f5738040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000";

        bytes memory part2 = hex"0000000000000000000000000000000000000000000000000000000000000000";

        return abi.encodePacked(part1, caller, part2);
    }


}
