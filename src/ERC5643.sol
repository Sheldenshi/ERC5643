// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/extension/Ownable.sol";
import "@thirdweb-dev/contracts/eip/ERC721A.sol";
import "./IERC5643.sol";
import {ERC721URIStorage} from "./ERC721URIStorage.sol";

error RenewalTooShort();
error RenewalTooLong();
error InsufficientPayment();
error SubscriptionNotRenewable();
error InvalidTokenId();
error CallerNotOwnerNorApproved();

contract MoonDAOEntity is ERC721URIStorage, IERC5643, Ownable {
    
    
    // For example: targeted subscription = 0.5 eth / 365 days.
    // pricePerSecond = 5E17 wei / 31536000 (seconds in 365 days)

    // Roughly calculates to 0.1 (1E17 wei) ether per 365 days.
    uint256 public pricePerSecond = 3150024690;

    // Discount for renewal more than 12 months. Denominator is 1000.
    uint256 public renewDiscount = 200;

    mapping(uint256 => uint64) private _expirations;

    uint64 internal minimumRenewalDuration;
    uint64 internal maximumRenewalDuration;

    constructor(string memory name_, string memory symbol_)
        ERC721A(name_, symbol_) 
    {
        _setupOwner(_msgSender());
    }

    function mintTo(address to, string calldata uri) external payable returns (uint256) {

        uint256 tokenId = _currentIndex;

        _mint(to, 1);
        _setTokenURI(tokenId, uri);

        renewSubscription(tokenId, 365 days);

        return tokenId;
    }

    /**
     * Allow owner to change the subscription price
     * @param _pricePerSecond new pricePerSecond
     */
    function setPricePerSecond(uint256 _pricePerSecond) external onlyOwner {
        pricePerSecond = _pricePerSecond;
    }


    /**
     * @dev See {IERC5643-renewSubscription}.
     */
    function renewSubscription(uint256 tokenId, uint64 duration)
        public
        payable
        virtual
    {
        // if (!_isApprovedOrOwner(msg.sender, tokenId)) {
        //     revert CallerNotOwnerNorApproved();
        // }

        if (duration < minimumRenewalDuration) {
            revert RenewalTooShort();
        } else if (
            maximumRenewalDuration != 0 && duration > maximumRenewalDuration
        ) {
            revert RenewalTooLong();
        }

        if (msg.value < _getRenewalPrice(tokenId, duration)) {
            revert InsufficientPayment();
        }

        _extendSubscription(tokenId, duration);
    }

    function setMinimumRenewalDuration(uint64 duration) external onlyOwner {
        _setMinimumRenewalDuration(duration);
    }

    function setMaximumRenewalDuration(uint64 duration) external onlyOwner {
        _setMaximumRenewalDuration(duration);
    }

    function setTokenURI(uint256 tokenId, string memory _uri) public {
        require(_isApprovedOrOwner(msg.sender, tokenId) || _msgSender() == owner(), "Only token owner or contract owner can set URI");
         if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        _setTokenURI(tokenId, _uri);
    }

    /**
     *  This function returns who is authorized to set the owner of your contract.
     *  Only allow the current owner to set the contract's new owner.
     */
    function _canSetOwner() internal virtual view override returns (bool) {
        return msg.sender == owner();
    }

    /**
     * @dev Extends the subscription for `tokenId` for `duration` seconds.
     * If the `tokenId` does not exist, an error will be thrown.
     * If a token is not renewable, an error will be thrown.
     * Emits a {SubscriptionUpdate} event after the subscription is extended.
     */
    function _extendSubscription(uint256 tokenId, uint64 duration)
        internal
        virtual
    {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }

        uint64 currentExpiration = _expirations[tokenId];
        uint64 newExpiration;
        if ((currentExpiration == 0) || (currentExpiration < block.timestamp)) {
            newExpiration = uint64(block.timestamp) + duration;
        } else {
            if (!_isRenewable(tokenId)) {
                revert SubscriptionNotRenewable();
            }
            newExpiration = currentExpiration + duration;
        }

        _expirations[tokenId] = newExpiration;

        emit SubscriptionUpdate(tokenId, newExpiration);
    }

    /**
     * @dev Gets the price to renew a subscription for `duration` seconds for
     * a given tokenId. This value is defaulted to 0, but should be overridden in
     * implementing contracts.
     */
    function _getRenewalPrice(uint256 tokenId, uint64 duration)
        internal
        view
        virtual
        returns (uint256)
    {
        uint256 price = duration * pricePerSecond;
        
        return duration >= 365 days ? price * (1000 - renewDiscount) / 1000  : price;
    }

    /**
     * @dev See {IERC5643-cancelSubscription}.
     */
    function cancelSubscription(uint256 tokenId) external payable virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert CallerNotOwnerNorApproved();
        }

        delete _expirations[tokenId];

        emit SubscriptionUpdate(tokenId, 0);
    }

    /**
     * @dev See {IERC5643-expiresAt}.
     */
    function expiresAt(uint256 tokenId)
        external
        view
        virtual
        returns (uint64)
    {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        return _expirations[tokenId];
    }

    /**
     * @dev See {IERC5643-isRenewable}.
     */
    function isRenewable(uint256 tokenId)
        external
        view
        virtual
        returns (bool)
    {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        return _isRenewable(tokenId);
    }

    /**
     * @dev Internal function to determine renewability. Implementing contracts
     * should override this function if renewabilty should be disabled for all or
     * some tokens.
     */
    function _isRenewable(uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        return true;
    }

    /**
     * @dev Internal function to set the minimum renewal duration.
     */
    function _setMinimumRenewalDuration(uint64 duration) internal virtual {
        minimumRenewalDuration = duration;
    }

    /**
     * @dev Internal function to set the maximum renewal duration.
     */
    function _setMaximumRenewalDuration(uint64 duration) internal virtual {
        maximumRenewalDuration = duration;
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = this.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    // Disable token transfers
    function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual override {
        require (from == address(0) || to == address(0), "You may not transfer your token!");
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC5643).interfaceId
            || super.supportsInterface(interfaceId);
    }
}
