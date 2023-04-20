// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "contracts/IMinterController.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Domain is IMinterController,ERC721{

    address public owner;
    //IMinterController public minter;
    uint256 public salePrice;
    

    constructor(uint256 _salePrice) ERC721("MyToken", "MTK") {
        owner=msg.sender;
        
        
        salePrice = _salePrice;
        referralPercentage[owner] = 20;
        referralPercentage[address(0)] = 10;
        
    }
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    mapping(uint256 => string) Tokenstorage;
    mapping(uint256 => address) _tokenResolvers;
    mapping(address => uint256) public referralPercentage;
    

    event DomainPurchased(address buyer, string domain, uint256 price);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    

    function setSalePrice(uint256 _salePrice) external onlyOwner {
        salePrice = _salePrice;
    }

    function setReferralPercentage(address _user, uint256 _percentage) external onlyOwner {
        require(_percentage <= 20, "Referral percentage cannot exceed 20%");
        referralPercentage[_user] = _percentage;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    


    function mintURI(address to, string calldata label) public {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        //_setTokenURI(newItemId, tokenURI);   this is depricated in solidity version ^0.8.0
        Tokenstorage[newItemId]=label;

        

    }

    function mintURIWithResolver(address to, string calldata label, address resolver) public{
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
       // _setTokenURI(newItemId, tokenURI);
        
        Tokenstorage[newItemId]=label;
        _setResolver(newItemId, resolver);

       
    }

    function _setResolver(uint256 tokenId, address resolver) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenResolvers[tokenId] = resolver;
    }
    function getResolver(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenResolvers[tokenId];
    }


    function buyDomain(string calldata _domain, address _referral) external payable {
        require(msg.value == salePrice, "Incorrect sale price");
        require(bytes(_domain).length > 0, "Domain name cannot be empty");
        require(_referral != msg.sender, "Cannot refer to yourself");

        uint256 referralAmount = (msg.value * referralPercentage[_referral]) / 100;
        uint256 paymentAmount = msg.value - referralAmount;

        payable(_referral).transfer(referralAmount);
        payable(owner).transfer(paymentAmount);


        emit DomainPurchased(msg.sender, _domain, msg.value);

        mintURI(msg.sender, _domain);

    }

    
    function buyDomainWithoutReferral(string calldata _domain) external payable {
        require(msg.value == salePrice, "Incorrect sale price");
        require(bytes(_domain).length > 0, "Domain name cannot be empty");

        payable(owner).transfer(msg.value);

        emit DomainPurchased(msg.sender, _domain, msg.value);

        mintURI(msg.sender, _domain);
    }

    
    function withdrawERC20(address tokenAddress, uint256 amount) public {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

}