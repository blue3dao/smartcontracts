//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//HRC721 contract to deploy and mint NFT
contract HRC721 is ERC721("Blue to Fly Collection", "BLUETOFLY"),ERC721Enumerable,ERC721URIStorage {
    using Counters for Counters.Counter;
    address private owner;
    uint256 expiryDate;
    string baseURI;
    mapping(uint256 => bool) tokenAirdropStatus;
    Counters.Counter private tokenIdCounter;
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
        require(owner == msg.sender, "Caller is not the owner");
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
        setBaseURI(_baseURIPath);
        bluTokenAddress = IERC20(_token);
        expiryDate = airdropExpiry;
        tokenIdCounter.increment();
    }

    //minting the NFT tokens by the owner of the contract
    function safemint(
        address _user,
        string[] memory _tokenURI
    ) public onlyOwner {
        for(uint i = 0; i < _tokenURI.length; i ++){
        _safeMint(_user, tokenIdCounter.current());
        _setTokenURI(tokenIdCounter.current(),_tokenURI[i]);
        tokenIdCounter.increment();
        emit Mint(msg.sender, _user, tokenIdCounter.current());
        }

    }

    function getTokenAirdropStatus(uint256 tokenID) public view returns (bool) {
        return tokenAirdropStatus[tokenID];
    }

    function updateAirdropStatus(uint256 tokenID, bool value) public onlyOwner
    {
        tokenAirdropStatus[tokenID] = value;
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
        safeTransferFrom(from, to, tokenID, "");
        emit TransferBLU(from, to, tokenID);
        airDropping(tokenID,to);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenID
    ) public override {
        safeTransferFrom(from, to, tokenID, "");
        emit TransferBLU(from, to, tokenID);
        airDropping(tokenID,to);
    }

   function airDropping(uint256  tokenID, address _to) private  {
       if(tokenAirdropStatus[tokenID]==false && !isExpired())   {
        if (tokenID >= 1 && tokenID <= 1000)
                bluTokenAddress.transfer(_to, 10 * 10 ** 18);
        else if (tokenID > 1000 && tokenID <= 1200)
                bluTokenAddress.transfer(_to, 50 * 10 ** 18);
        else if (tokenID > 1200 && tokenID <= 1250)
                bluTokenAddress.transfer(_to, 100 * 10 ** 18);
       }
        
        tokenAirdropStatus[tokenID] = true;
        emit AirDrop(_to, tokenID);
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
