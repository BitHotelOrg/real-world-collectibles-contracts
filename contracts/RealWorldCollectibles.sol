// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RealWorldCollectibles is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;

    struct Collectible {
        string nfcUuid;
        address artist;
        uint256 createdDate;
    }

    Counters.Counter private _tokenIdCounter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address[] private _owners;
    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    string private _baseTokenURI;

    mapping(uint256 => Collectible) private _collectibles;
    mapping(uint256 => address[]) private _ownersHistory;

    event CollectibleInfoAdded(uint256 tokenId, string uuid, address artist, uint256 createdDate);
    /**
     * @dev Emitted when `tokenId` nft is minted to `to`.
    */
    event TokenMint(uint256 tokenId, address to);

    /**
     * @dev Emitted when `setBaseURI` is change to `newBaseTokenURI`.
    */
    event BaseUriChanged(string oldBaseTokenURI, string newBaseTokenURI);

  
    constructor(
        string memory mName,
        string memory mSymbol
    ) ERC721(mName, mSymbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment(); // make sure tokenId starts with 1
    }

    function tokenIds() external view returns (uint256[] memory) {
        return _allTokens;
    }

    function ownersHistory(uint256 tokenId) external view returns (address[] memory) {
        return _ownersHistory[tokenId];
    }

    function getCollectibleInfos(uint256 tokenId) external virtual view returns (string memory, address, uint256 ) {
        string memory uuid = _collectibles[tokenId].nfcUuid;
        address artist = _collectibles[tokenId].artist;
        uint256 createdDate = _collectibles[tokenId].createdDate;
        return(uuid, artist, createdDate);
    }

    function setCollectibleInfos(
        uint256 tokenId,
        string memory uuid,
        address artist
    ) external onlyRole(MINTER_ROLE) {
        require(tokenId != 0, "tokenId is the zero value");
        Collectible storage c = _collectibles[tokenId];
        c.nfcUuid = uuid;
        c.artist = artist;
        c.createdDate = block.timestamp; 
        emit CollectibleInfoAdded(tokenId, uuid, artist, c.createdDate);
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory newBaseTokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        string memory oldBaseTokenURI = baseURI();
        _baseTokenURI = newBaseTokenURI;
        emit BaseUriChanged(oldBaseTokenURI, newBaseTokenURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_exists(tokenId), "change uri for nonexistent token");
        _setTokenURI(tokenId, tokenURI_);
    }

    function mint(
        address to,
        string memory uri
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();

        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _allTokens.push(tokenId);
        emit TokenMint(tokenId, to);
    }

    function safeMint(
        address to,
        string memory uri,

        bytes memory data_ 
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        super._safeMint(to, tokenId, data_);
        _setTokenURI(tokenId, uri);
        _allTokens.push(tokenId);
        emit TokenMint(tokenId, to);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) 
        internal
        virtual
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
        // add owner to _ownersHistory
        _ownersHistory[tokenId].push(to);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) 
        internal
        virtual
        override(ERC721, ERC721URIStorage)
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        super._burn(tokenId);
    }
}