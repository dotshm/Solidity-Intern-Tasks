
# Develop a smart contract that enables the sale of dotshm domains on top of an existing contract. 

Add the following features into the contract

1. Add custom referral to the contract with a maximum cap of 20% of the sale price. By default, each user will have a referral percentage of 10%, which can be customized up to 20% for different addresses by the owner.

2. Create two functions to allow the purchase of domains with or without a referral.

3. The sale price of domains should be customizable by the owner of the contract.

4. Add logic to pay referral share in the same buy domain functions.

5. Create a withdraw function to allow the withdrawal of ETH from the contract.

6. Create additional withdrawERC20 function to enable the withdrawal of unwanted ERC20 tokens from the contract.


Optional tasks :

1. Restricting the referral system to only registered domain holders, allowing only existing dotshm domain holders to refer new users.

2. Transfer of domain sale price directly to the Owner in the buy domain function.

3. Create a onlyOwner function that reserves domains free of cost.

Helping Material : 
1. Interface of minting contract is attached in the repository


How to submit task
1. Fork this repository(Keep it private)

2. Push task to the forked repository

3. Add @dotshm as a contributor to review the task.
