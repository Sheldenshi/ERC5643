// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { MoonDAOEntity } from "./ERC5643.sol";
import "@hats/Interfaces/IHats.sol";
import "./IMoonDAOEntityCreator.sol";
import "./GnosisSafeProxyFactory.sol";
import "./GnosisSafeProxy.sol";

contract MoonDAOEntityCreator is IMoonDAOEntityCreator {

    IHats internal hats;

    MoonDAOEntity internal moonDAOEntity;

    address internal gnosisSingleton;

    GnosisSafeProxyFactory internal gnosisSafeProxyFactory;

    constructor(address _hats, address _moonDAOEntity, address _gnosisSingleton, address _gnosisSafeProxyFactory) {
        hats = IHats(_hats);
        moonDAOEntity = MoonDAOEntity(_moonDAOEntity);
        gnosisSingleton = _gnosisSingleton;
        gnosisSafeProxyFactory = GnosisSafeProxyFactory(_gnosisSafeProxyFactory);
    }

    function createMoonDAOEntity(string calldata metaDataUri, string calldata hatsUri) external payable returns (uint256){
        bytes memory safeCallData = constructSafeCallData(msg.sender);
        GnosisSafeProxy gnosisSafe = gnosisSafeProxyFactory.createProxy(gnosisSingleton, safeCallData);
        
        //mint hat
        uint256 hatId = hats.mintTopHat(address(gnosisSafe), hatsUri, "");

        uint256 tokenId = moonDAOEntity.mintTo{value: msg.value}(address(gnosisSafe), metaDataUri, hatId, msg.sender);
        return tokenId;

    }

    function constructSafeCallData(address caller) internal returns (bytes memory) {
        bytes memory part1 = hex"b63e800d0000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140000000000000000000000000017062a1de2fe6b99be3d9d37841fed19f5738040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000";

        bytes memory part2 = hex"0000000000000000000000000000000000000000000000000000000000000000";

        return abi.encodePacked(part1, caller, part2);
    }


}