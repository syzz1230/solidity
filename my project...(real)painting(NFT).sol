// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*Create a smart contract in solidity To Tokenize All The Assets(Paintings) That are listed on and Buy Sell Platform with following functionalities 

1) Anyone Can come and list the product that they want to sell.
2) Buyer can come and make payment for that and buy it.
3) Automatically a NFT will be minted for that partiular asset and ownership of that NFT will be transferred to the Buyer.
4) All Required View Functions.
1000000000000000000*/


//importing libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//using multiple inheritance here
contract PaintingToken is ERC721, Ownable {
    uint256 public nextTokenId;

    struct Painting {
        address seller;
        uint256 price;
        string metadata;
        bool exists;
    }

    mapping(uint256 => Painting) public paintings;

    constructor() ERC721("PaintingToken", "PT") {}
//function for uploading the painting
    function listPainting(uint256 _price, string memory _metadata) public {
        require(_price > 0, "Price must be greater than zero");
        nextTokenId++;
        paintings[nextTokenId] = Painting(msg.sender, _price, _metadata, true);
        _mint(msg.sender, nextTokenId);
    }
//function for  buying the painting
    function buyPainting(uint256 _tokenId) public payable {
        Painting memory painting = paintings[_tokenId];
        require(painting.exists, "Painting does not exist");
        require(msg.value >= painting.price, "Not enough funds");
        address payable seller = payable(painting.seller);
        seller.transfer(msg.value);
        _transfer(painting.seller, msg.sender, _tokenId);
        delete paintings[_tokenId];
    }
//function for showing the tokenURI
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        Painting memory painting = paintings[_tokenId];
        require(painting.exists, "Painting does not exist");
        return painting.metadata;
    }
//function for minting the NFT 
    function mintNFT(address _to, uint256 _tokenId) public onlyOwner {
        _mint(_to, _tokenId);
    }
}