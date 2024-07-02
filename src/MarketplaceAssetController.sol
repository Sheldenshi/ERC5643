pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MoonDAOTeam} from "./ERC5643.sol";
import {MarketPlace} from "./MarketPlace.sol";

contract MarketplaceAssetController is Ownable{
  MarketPlace marketplace;
  bytes32 assetRole;
  MoonDAOTeam public _moonDaoTeam;

  constructor(address _marketplace, bytes32 _assetRole, address moonDaoTeam) Ownable(msg.sender) {
    marketplace = MarketPlace(_marketplace);
    assetRole = _assetRole;
    _moonDaoTeam = MoonDAOTeam(moonDaoTeam);
  }

   function setMoonDaoTeam(address moonDaoTeam) external onlyOwner{
        _moonDaoTeam = MoonDAOTeam(moonDaoTeam);
    }

  function setMarketplace(address _marketplace) public onlyOwner{
    marketplace = MarketPlace(_marketplace);
  }

  function setAssetRole(bytes32 _assetRole) public onlyOwner {
    assetRole = _assetRole;
  }

  function addCollection(uint teamId, address collection) public {
    // check that the msg.sender is an admin/owner of the team
    require (_moonDaoTeam.isManager(teamId, msg.sender), "Only Admin can add collection");

    // grantRole to collection
    marketplace.grantRole(assetRole, collection);
  }
}

