pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MoonDAOEntity} from "./ERC5643.sol";
import {MarketPlace} from "./MarketPlace.sol";

contract MarketplaceAssetController is Ownable{
  MarketPlace marketplace;
  bytes32 assetRole;
  MoonDAOEntity public _moonDaoEntity;

  constructor(address _marketplace, bytes32 _assetRole, address moonDaoEntity) Ownable(msg.sender) {
    marketplace = MarketPlace(_marketplace);
    assetRole = _assetRole;
    _moonDaoEntity = MoonDAOEntity(moonDaoEntity);
  }

   function setMoonDaoEntity(address moonDaoEntity) external onlyOwner{
        _moonDaoEntity = MoonDAOEntity(moonDaoEntity);
    }

  function setMarketplace(address _marketplace) public onlyOwner{
    marketplace = MarketPlace(_marketplace);
  }

  function setAssetRole(bytes32 _assetRole) public onlyOwner {
    assetRole = _assetRole;
  }

  function addCollection(uint entityId, address collection) public {
    // check that the msg.sender is an admin/owner of the entity
    require (_moonDaoEntity.isManager(entityId, msg.sender), "Only Admin can add collection");

    // grantRole to collection
    marketplace.grantRole(assetRole, collection);
  }
}

