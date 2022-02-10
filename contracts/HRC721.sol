//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract HRC721 is ERC721("Blu3DAO","Blu3"){
    mapping(uint256 => int256) private tokenIdMappings;
    address addressOwner;
    address private owner;
    uint expiryDate;

    ERC20 bluTokenAddress;

    struct Metadata{
        uint256 tokenID;
        string tokenURI;
        uint256 timestamp;
    }

    mapping(uint256 => Metadata) public metadataMappings;

    constructor(ERC20 _token,uint airdropExpiry) {
     for(uint256 i=1; i<=1250; i++) {
           tokenIdMappings[i] = -1;
        }
     bluTokenAddress = _token;
     owner = msg.sender;
     expiryDate=airdropExpiry;
    }

    function safemint(address user,uint256 tokenID, string memory tokenURI) public {
      require(owner == msg.sender);
      _safeMint(user, tokenID); 
        metadataMappings[tokenID] = Metadata({timestamp: block.timestamp, tokenID: tokenID, tokenURI: tokenURI});
    }

    function getToken(uint256 tokenID) public view returns (int256) {
        return tokenIdMappings[tokenID];
    }

    function safeTransfer(address from, address to, uint256 tokenID) public
    {
       safeTransferFrom(from,to,tokenID);
       tokenIdMappings[tokenID]++;
       if(tokenIdMappings[tokenID]==0 && !isExpired())
       {
           if(tokenID>=1 && tokenID <=1000)
             bluTokenAddress.transfer(to,10);
           else if(tokenID>1000 && tokenID <=1200)
             bluTokenAddress.transfer(to,50);  
           else if(tokenID>1200 && tokenID <=1250)
              bluTokenAddress.transfer(to,100);    
       }
    }

     function isExpired() private view returns (bool) {
        return (block.timestamp >= expiryDate);
  }
     
}