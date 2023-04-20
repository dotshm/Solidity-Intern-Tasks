// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Defining an interface for the Minter Controller contract
interface IMinterController {
    function mintURI(address to, string calldata label) external;
    function mintURIWithResolver(address to, string calldata label, address resolver) external;
}

contract DotshmDomainMarketplace {
    IMinterController public minter;
    address public owner;
    mapping(address => uint256) public referralPercentages;  // mapping to hold referral percentages for each address
    uint256 public defaultReferralPercentage = 10;
    uint256 public referralCap = 20;
    mapping(string => uint256) public domainPrices;          // mapping to hold the prices for each domain


    // Defining the constructor function that takes an instance of the Minter Controller contract as an argument
    constructor(IMinterController _minter) {
        minter = _minter;
        owner = msg.sender;
    }
    // Defining a function to set the price of a domain and it can be done by onlyOwner
    function setDomainPrice(string memory label, uint256 price) external onlyOwner {
        domainPrices[label] = price;   // Setting the price of the specified domain
    } 
    
    // Defining a function to set the referral percentage for an address and it can only done by owner
    function setReferralPercentage(address referrer, uint256 percentage) external onlyOwner {
        require(percentage <= referralCap, "Referral percentage exceeds cap");   // Checking that the referral percentage is within the referral cap
        referralPercentages[referrer] = percentage;                              // Setting the referral percentage for the specified address
    }
    

    // Function to buy a domain without referral
    function buyDomainWithOutReferral(string memory label) payable public {
        uint256 price = domainPrices[label];                          // Getting the price of the domain
        require(price > 0, "Domain not for sale");                    // Checking that the domain is for sale
        uint256 referralPercentage = referralPercentages[msg.sender]; // Get the referral percentage 

        // Setting the default referral percentage if the owner has not set a referral percentage
        if (referralPercentage == 0) {
            referralPercentage = defaultReferralPercentage;
        }
        require(msg.value >= price, "Insufficient funds to purchase domain"); // Checking that the buyer has sent enough ether to purchase the domain
        uint256 referralFee = price * referralPercentage / 100;               // Calculating the referral fee
        uint256 sellerPayment = price - referralFee;                          // Calculating the payment to the seller

        // Transferring the referral fee to the referrer
        if (referralFee > 0) {
            payable(msg.sender).transfer(referralFee);
        }

        // Transferring the payment to the seller
        if (sellerPayment > 0) {
            payable(owner).transfer(sellerPayment);
        }
        minter.mintURI(msg.sender, label);                            // Minting the domain NFT and assigning ownership to the buyer
    }


    // Function to buy a domain with referral
    function buyDomainWithReferral(string memory label, address referrer) payable public {
        uint256 price = domainPrices[label];                                         // Getting the price of the domain
        require(price > 0, "Domain not for sale");                                   // Checking that the domain is for sale
        require(referrer != msg.sender, "Cannot refer yourself");                    // ensuring that referrer can't refer to himself
        uint256 referralPercentage = referralPercentages[referrer];                  // Get the referral percentage 
        require(referralPercentage > 0, "Referral not eligible for this domain");    // Ensure the referrer is eligible for the referral program
        require(msg.value >= price, "Insufficient funds to purchase domain");        // Check if the amount sent is sufficient to purchase the domain
        uint256 referralFee = price * referralPercentage / 100;                       // Calculate referral fee as a percentage of the domain price
        uint256 sellerPayment = price - referralFee;                               // Calculate the payment for the seller


        // Transfer referral fee to the referrer
        if (referralFee > 0) {
            payable(referrer).transfer(referralFee);
        }

        // Transfer payment for the domain to the owner/seller
        if (sellerPayment > 0) {
            payable(owner).transfer(sellerPayment);
        }

        // Mint the domain to the buyer
        minter.mintURI(msg.sender, label);
    }


    // Transfer the contract's balance to the owner's address
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawERC20(address token) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(address(this));                 // Get the balance of the ERC20 token
        require(balance > 0, "No tokens to withdraw");                    // Ensure there are tokens to withdraw
        require(erc20.transfer(owner, balance), "Token transfer failed"); // Transfer the tokens to the owner's address
    }

    // Modifier that restricts function access to only the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
}
