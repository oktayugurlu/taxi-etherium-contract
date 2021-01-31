# Taxi Invesment Partnership Etherium Contract
This smart contract handles a common asset and distribution of income generated from this asset in certain time intervals. The common asset in this scenario is a taxi.
A group of people who would like to  combine their holdings together to buy a car which will be used as a taxi and the profit will be shared
among participants every month. However, one problem is that they have no trust in each other. The smart contract that will handle the transactions. The contract can run on Ethereum network. The contract includes some state variables and functions which you can see below:
## State Variables
### - Participants: 
maximum of 9, each participant identified with an address and has a balance
### - Manager: 
a manager that is decided offline who creates the contract initially.
### - Taxi Driver: 
1 taxi driver and salary
### - Car Dealer: 
An identity to buy/sell car, also handles maintenance and tax
### - Contract balance: 
Current total money in the contract that has not been distributed
### - Fixed expenses: 
Every 6 months car needs to go to Car Dealer for maintenance and taxes needs to be
paid, total amount for maintenance and tax is fixed and 10 Ether for every 6 months.
### - Participation fee:
An amount that participants needs to pay for entering the taxi business, it is fixed and
100 Ether.
### - Owned Car: 
identified with a 32 digit number, CarID
### - Proposed Car: 
Car proposal proposed by the CarDealer, Holds {CarID, price, offer valid time and approval
state } information.
### - Proposed Repurchase: 
Car repurchase proposal proposed by the CarDealer, Holds {CarID (the owned
car id), price, offer valid time, and approval state} information.

## Functions
### - Constructor:
Called by owner of the contract and sets the manager and other initial values for state variables
### - Join function:
Public, Called by participants, Participants needs to pay the participation fee set in the contract to be a
member in the taxi investment
### - SetCarDealer:
Only Manager can call this function, Sets the CarDealer’s address
### - CarProposeToBusiness:
Only CarDealer can call this, sets Proposed Car values, such as CarID, price, offer valid time and
approval state (to 0)
### - ApprovePurchaseCar:
Participants can call this function, approves the Proposed Purchase with incrementing the approval
state. Each participant can increment once.
### - PurchaseCar:
Only Manager can call this function, sends the CarDealer the price of the proposed car if the offer valid
time is not passed yet and approval state is approved by more than half of the participants.
### - RepurchaseCarPropose:
Only CarDealer can call this, sets Proposed Purchase values, such as CarID, price, offer valid time and
approval state (to 0)
### - ApproveSellProposal:
Participants can call this function, approves the Proposed Sell with incrementing the approval state.
Each participant can increment once.
### - Repurchasecar:
Only CarDealer can call this function, sends the proposed car price to contract if the offer valid time is
not passed yet and approval state is approved by more than half of the participants.
### - ProposeDriver:
Only Manager can call this function, sets driver address, and salary.
### - ApproveDriver:
Participants can call this function, approves the Proposed Driver with incrementing the approval state.
Each participant can increment once.
### - SetDriver:
Only Manager can call this function, sets the Driver info if approval state is approved by more than half
of the participants. Assume there is only 1 driver.
### - FireDriver:
Only Manager can call this function, gives the full month of salary to current driver’s account.
### - PayTaxiCharge:
Public, customers who use the taxi pays their ticket through this function. Charge is sent to contract.
Takes no parameter. See slides 6 page 11.
### - ReleaseSalary:
Only Manager can call this function, releases the salary of the Driver to his/her account monthly. Make
sure Manager is not calling this function more than once in a month.
### - GetSalary:
Only Driver can call this function, if there is any money in Driver’s account, it will be send to his/her
address
### - PayCarExpenses:
Only Manager can call this function, sends the CarDealer the price of the expenses every 6 month.
Make sure Manager is not calling this function more than once in the last 6 months.
### - PayDividend:
Only Manager can call this function, calculates the total profit after expenses and Driver salaries,
calculates the profit per participant and releases this amount to participants in every 6 month. Make sure
Manager is not calling this function more than once in the last 6 months.
### - GetDividend:
Only Participants can call this function, if there is any money in participants’ account, it will be send to
his/her address
## Important Notes:

- The contract is developed in Solidity v0.8.0 and should be complied in this version.

- Because to make easier to testing of the functions, the messages are set in revert
function. So, it causes to increse gas limit. For this reason, the gas limit should be set as 5000000

- For parameters of the function repurchaseCarPropose(), price_ should be sent in
	  wei, and the offeredValidTime.

- For proposeDriver(), salary_ should be called in wei.

- Manager address should be passed while deploying.

- After the contract set, for first pay dividend, the participants should be wait for 6 months.
