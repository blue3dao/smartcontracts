//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//HRC721 contract to deploy and mint NFT
contract HRC721 is ERC721("Blu3DAO", "Blu3") {
    mapping(uint256 => int256) private tokenIdMappings;
    address addressOwner;
    address private owner;
    uint256 expiryDate;

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

    struct Metadata {
        uint256 tokenID;
        string tokenURI;
        uint256 timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    //metadata to the tokenID mapping
    mapping(uint256 => Metadata) public metadataMappings;

    constructor(address _token, uint256 airdropExpiry) {
        for (uint256 i = 1; i <= 1250; i++) {
            tokenIdMappings[i] = -1;
        }
        bluTokenAddress = IERC20(_token);
        owner = msg.sender;
        expiryDate = airdropExpiry;
    }

    //minting the NFT tokens by the owner of the contract
    function safemint(
        address _user,
        uint256 tokenID,
        string memory tokenURI
    ) public onlyOwner {
        _safeMint(_user, tokenID);
        metadataMappings[tokenID] = Metadata({
            timestamp: block.timestamp,
            tokenID: tokenID,
            tokenURI: tokenURI
        });
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
                bluTokenAddress.transfer(to, 10);
            else if (tokenID > 1000 && tokenID <= 1200)
                bluTokenAddress.transfer(to, 50);
            else if (tokenID > 1200 && tokenID <= 1250)
                bluTokenAddress.transfer(to, 100);
            emit AirDrop(to, tokenID);
        }
    }

    function isExpired() private view returns (bool) {
        return (block.timestamp >= expiryDate);
    }

    function updateExpiry(uint256 timestamp) public onlyOwner {
        require(timestamp > block.timestamp);
        expiryDate = timestamp;
    }
}
