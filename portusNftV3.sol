// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "https://github.com/nibbstack/erc721/src/contracts/tokens/nf-token-metadata.sol";

import "https://github.com/nibbstack/erc721/src/contracts/ownership/ownable.sol";

contract PortusNftV3 is NFTokenMetadata, Ownable {

  mapping (uint256 => uint256) internal idToPrice;
 
  constructor() {
    nftName = "PortusArtCollection";
    nftSymbol = "PORTUS";
  }

  function _setPrice(uint256 _tokenId, uint256 _price) internal validNFToken(_tokenId){
    idToPrice[_tokenId] = _price;
  }

  function tokenPrice(uint256 _tokenId) public view validNFToken(_tokenId) returns (uint256){
    return idToPrice[_tokenId];
  }
 
  function mint(address _to, uint256 _tokenId, string calldata _uri, uint256 _price) public{
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
    _setPrice(_tokenId, _price);
  }

  function buyNFT(uint256 _tokenId) public payable validNFToken(_tokenId) {

    address seller_address = idToOwner[_tokenId]; // query NFT's owner address
    address buyer_address = msg.sender; // buyer address
    uint256 token_price = idToPrice[_tokenId]; // wei

    // owner should not be able to buy his/her own artwork
    require(buyer_address != seller_address, "you can not buy your own NFT");

    //check if msg.value >= token_price in wei
    require(msg.value >= token_price, "not enough token to buy NFT");

    // make a payment
    (bool success, ) = seller_address.call{value: msg.value}("");
    require(success, "fail");

    // transfer NFT
    _transfer(buyer_address, _tokenId);
  }
}