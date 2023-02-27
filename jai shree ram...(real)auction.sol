//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {
    //global variables
    address payable public owner;
    
    struct AuctionDetails {
        string description;
        uint startTime;
        uint endTime;
        uint minBidValue;
        bool active;
        mapping(address => uint) bids;
        address[] bidders;
        address winner;
        bool closed;
    }
    
    mapping(uint => AuctionDetails) public auctions;
    uint public auctionCount;
    //for all the main event that are necessary for this contract
    event AuctionCreated(uint auctionID, string description, uint startTime, uint endTime, uint minBidValue);
    event BidPlaced(uint auctionID, address bidder, uint bidValue);
    event AuctionClosed(uint auctionID, address winner, uint winningBid);
    
    constructor() {
        owner = payable(msg.sender);
        auctionCount = 0;
    }
    modifier auctionActive(uint _auctionID) {
    require(auctions[_auctionID].active, "Auction is not active.");
    _;
    }
    //function for creating and starting an auction
    function createAuction(string memory _description, uint _startTime, uint _endTime, uint _minBidValue) public {
        require(_endTime > _startTime, "End time must be after start time.");
        require(_minBidValue > 0 , "Minimum bid value must be greater than zero.");
        require(_startTime > block.timestamp, "Start time must be in the future.");
        require(msg.sender == owner, "Only the owner can create auctions.");
        //auctionID for particlular auction
        uint auctionID = auctionCount;
        auctions[auctionID].description = _description;
        auctions[auctionID].startTime = _startTime;
        auctions[auctionID].endTime = _endTime;
        auctions[auctionID].minBidValue = _minBidValue;
        auctions[auctionID].active = true;
        
        auctionCount++;
        
        emit AuctionCreated(auctionID, _description, _startTime, _endTime, _minBidValue);
    }
    //function for placing bid by an bidder
    function placeBid(uint _auctionID, uint _bidValue) public payable auctionActive(_auctionID){
        require(msg.value == _bidValue, "Bid value must match sent Ether.");
        require(auctions[_auctionID].active =true, "Auction is not active.");
        require(_bidValue >= auctions[_auctionID].minBidValue, "Bid value is too low.");
        require(msg.sender != owner, "Owner cannot bid on their own auction.");
        
        auctions[_auctionID].bids[msg.sender] = _bidValue;
        auctions[_auctionID].bidders.push(msg.sender);
        
        emit BidPlaced(_auctionID, msg.sender, _bidValue);
    }
    //function for getting list of the bidders 
    function getBiddersList(uint _auctionID) public view returns(address[] memory) {
        require(msg.sender == owner, "Only the auction owner can view bid list.");
        return auctions[_auctionID].bidders;
    }
    //function which tell about the current bid of the particular bidder
    function getBidValue(uint _auctionID, address _bidder) public view returns(uint) {
        require(msg.sender == owner || msg.sender == _bidder, "Only the auction owner or bidder can view bid value.");
        return auctions[_auctionID].bids[_bidder];
    }
    //function to close the auction and announce the winner
    function closeAuction(uint _auctionID, address _winner)  public {
        require(msg.sender == owner, "Only the auction owner can close the auction.");
        require(auctions[_auctionID].active, "Auction is not active.");
        require(_winner != address(0), "Invalid winner address.");
        require(auctions[_auctionID].bids[_winner] > 0, "Winner must have placed a bid.");
        
        auctions[_auctionID].winner = _winner;
        auctions[_auctionID].closed = true;
        auctions[_auctionID].active = false;
    
        uint winningBid = auctions[_auctionID].bids[_winner];
        payable(_winner).transfer(winningBid);
    
        emit AuctionClosed(_auctionID, _winner, winningBid);

    }

}
