// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { MoonDAOEntity } from "./ERC5643.sol";
import "@hats/Interfaces/IHats.sol";
import "./IMoonDAOEntityCreator.sol";
import "./GnosisSafeProxyFactory.sol";
import "./GnosisSafeProxy.sol";
import {MoonDaoEntityTableland} from "./tables/MoonDaoEntityTableland.sol";

contract MoonDAOEntityCreator {

    IHats internal hats;

    MoonDAOEntity internal moonDAOEntity;

    address internal gnosisSingleton;

    GnosisSafeProxyFactory internal gnosisSafeProxyFactory;

    MoonDaoEntityTableland public table;

    constructor(address _hats, address _moonDAOEntity, address _gnosisSingleton, address _gnosisSafeProxyFactory, address _table) {
        hats = IHats(_hats);
        moonDAOEntity = MoonDAOEntity(_moonDAOEntity);
        gnosisSingleton = _gnosisSingleton;
        gnosisSafeProxyFactory = GnosisSafeProxyFactory(_gnosisSafeProxyFactory);
        table = MoonDaoEntityTableland(_table);
    }

    function createMoonDAOEntity(string calldata name, string calldata bio, string calldata image, string calldata twitter, string calldata communications, string calldata website, string calldata _view, string calldata hatsUri) external payable returns (uint256 tokenId, uint256 childHatId){
        bytes memory safeCallData = constructSafeCallData(msg.sender);
        GnosisSafeProxy gnosisSafe = gnosisSafeProxyFactory.createProxy(gnosisSingleton, safeCallData);
        
        //mint hat
        uint256 hatId = hats.mintTopHat(address(this), hatsUri, "");

        childHatId = hats.createHat(hatId, "", 8, msg.sender, msg.sender, true, "");

        hats.mintHat(childHatId, msg.sender);

        hats.transferHat(hatId, address(this), address(gnosisSafe));

        tokenId = moonDAOEntity.mintTo{value: msg.value}(address(gnosisSafe), hatId);

        table.insertIntoTable(tokenId, name, bio, image, twitter, communications, website, _view);
    }

    function constructSafeCallData(address caller) internal returns (bytes memory) {
        bytes memory part1 = hex"b63e800d0000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140000000000000000000000000017062a1de2fe6b99be3d9d37841fed19f5738040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000";

        bytes memory part2 = hex"0000000000000000000000000000000000000000000000000000000000000000";

        return abi.encodePacked(part1, caller, part2);
    }


}
