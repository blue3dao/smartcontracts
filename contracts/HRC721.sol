//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//HRC721 contract to deploy and mint NFT
contract HRC721 is ERC721("Blue to Fly Collection", "BLUETOFLY"),ERC721Enumerable,ERC721URIStorage {
    mapping(uint256 => int256) private tokenIdMappings;
    address addressOwner;
    address private owner;
    uint256 expiryDate;
    string baseURI;

    //token that needed to be airdropped
    IERC20 bluTokenAddress;

    //event to be emmitted when the minting is succeeded
    event Mint(address indexed _from, address indexed _to, uint256 _tokenId);

    //emit when someone transfering/buying BLU NFT
    event TransferBLU(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );

    //emitting Airdrop event whenever the tokens are airdropped to an address
    event AirDrop(address indexed _to, uint256 _tokenId);

    modifier onlyOwner() {
        require(owner == owner, "Caller is not the owner");
        _;
    }

     function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

   function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    constructor(address _token, uint256 airdropExpiry, string memory _baseURIPath) {
        owner = msg.sender;
        for (uint256 i = 1; i <= 1250; i++) {
            tokenIdMappings[i] = -1;
        }
        setBaseURI(_baseURIPath);
        bluTokenAddress = IERC20(_token);
        expiryDate = airdropExpiry;
    }

    //minting the NFT tokens by the owner of the contract
    function safemint(
        address _user,
        uint256 tokenID,
        string memory _tokenURI
    ) public onlyOwner {
        _safeMint(_user, tokenID);
        _setTokenURI(tokenID,_tokenURI);
        emit Mint(msg.sender, _user, tokenID);
    }

    function getToken(uint256 tokenID) public view returns (int256) {
        return tokenIdMappings[tokenID];
    }

    /*
    tranfering the NFT token from one user to another and 
    if an NFT is first time then the user will be airdropped with the social tokens
    */
    function safeTransfer(
        address from,
        address to,
        uint256 tokenID
    ) public {
        safeTransferFrom(from, to, tokenID);
        emit TransferBLU(from, to, tokenID);
        tokenIdMappings[tokenID]++;
        if (tokenIdMappings[tokenID] == 0 && !isExpired()) {
            if (tokenID >= 1 && tokenID <= 1000)
                bluTokenAddress.transfer(to, 10 * 10 ** 18);
            else if (tokenID > 1000 && tokenID <= 1200)
                bluTokenAddress.transfer(to, 50 * 10 ** 18);
            else if (tokenID > 1200 && tokenID <= 1250)
                bluTokenAddress.transfer(to, 100 * 10 ** 18);
            emit AirDrop(to, tokenID);
        }
    }

function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

    function isExpired() private view returns (bool) {
        return (block.timestamp >= expiryDate);
    }

    function updateExpiry(uint256 timestamp) public onlyOwner {
        require(timestamp > block.timestamp);
        expiryDate = timestamp;
    }
}
