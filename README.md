# taxi-etherium-contract

Important Notes:

	- The contract is developed in Solidity v0.8.0 and should be complied in this version.

	- Because to make easier to testing of the functions, the messages are set in revert
	  function. So, it causes to increse gas limit. For this reason, the gas limit should be set as 5000000

	- For parameters of the function repurchaseCarPropose(), price_ should be sent in
	  wei, and the offeredValidTime.

	- For proposeDriver(), salary_ should be called in wei.

	- Manager address should be passed while deploying.

	- After the contract set, for first pay dividend, the participants should be wait for 6 months.
