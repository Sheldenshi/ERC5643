// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../ERC5643.sol";

contract MoonDaoEntityERC5643 is Ownable, ERC5643 {
    // Roughly calculates to 0.1 ether per 30 days
    uint256 public pricePerSecond = 38580246913;

    uint256 private _nextTokenId;

    bool renewable = true;

    // Discount for renewal more than 12 months. Denominator is 1000.
    uint256 public renewDiscount = 200;

    constructor(string memory name_, string memory symbol_)
        ERC5643(name_, symbol_)
    {}

    /**
     * Allow owner to change the subscription price
     * @param _pricePerSecond new pricePerSecond
     */
    function setPricePerSecond(uint256 _pricePerSecond) external onlyOwner {
        pricePerSecond = _pricePerSecond;
    }

    function mint(address to, string memory tokenURI) public returns (uint256) {

        uint256 tokenId = _nextTokenId++;

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }


    function mintWithSubscription(address to, uint64 duration, string memory tokenURI)
        payable
        public returns (uint256)
    {
        uint256 tokenId = _nextTokenId++;

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        renewSubscription(tokenId, duration);
        return tokenId;
    }

    function _getRenewalPrice(uint256 tokenId, uint64 duration)
        internal
        view
        override
        returns (uint256)
    {   
        uint256 price = duration * pricePerSecond;
        
        return duration >= 3153600 ? price * (1000 - renewDiscount) / 1000  : price;
    }

    function _isRenewable(uint256 tokenId)
        internal
        view
        override
        returns (bool)
    {
        return renewable;
    }

    function setRenewable(bool _renewable) external onlyOwner {
        renewable = _renewable;
    }

    function setMinimumRenewalDuration(uint64 duration) external onlyOwner {
        _setMinimumRenewalDuration(duration);
    }

    function setMaximumRenewalDuration(uint64 duration) external onlyOwner {
        _setMaximumRenewalDuration(duration);
    }

    /**
     * @dev This function is used soley for testing purposes and shouldn't be used
     * in a standalone fashion.
     */
    function extendSubscription(uint256 tokenId, uint64 duration) external {
        _extendSubscription(tokenId, duration);
    }

    // Disable token transfers
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        require (from == address(0) || to == address(0), "You may not transfer your token!");
    }

    function setTokenURI(uint256 tokenId, string memory _uri) public {
        require(_isApprovedOrOwner(msg.sender, tokenId) || _msgSender() == owner(), "Only token owner or contract owner can set URI");
         if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        _setTokenURI(tokenId, _uri);
    }



    
}