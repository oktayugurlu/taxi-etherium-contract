// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

    
contract Taxi{
    
    // isSalaryPayedForEachMonth is initialized as 12 length, if initial month is payed, according to index is sets true 
    struct TaxiDriver{
        address payable driverAddress;
        uint salary;
        uint driverBalance;
        uint timestampOfLastPayedMonth;
    }
    
    struct ProposedTaxiDriver{
        address driverAddress;
        uint salary; 
        uint approvalState; // approval state
        address[] approvedParticipantsForProposedTaxiDriver;
    }
    
    struct Car{
        uint carID;
        uint lastExpansesTimestamp;
    }
    
    struct ProposedCar{
        uint carID;
        uint price; 
        uint offerValidTime;
        uint approvalState; // approval state
        address[] approvedParticipantsForProposedCar;
    }
    
    struct ProposedRepurchase{
        uint ownedCarID;
        uint price;
        uint offerValidTime;
        uint approvalState; // approval state
        address[] approvedParticipantsForProposedRepurchase;
    }
    
    mapping(address => uint) private participants;
    
    address private manager;
    TaxiDriver taxiDriver;
    address private carDealer;
    uint private contractBalance;
    uint private fixedExpenses;
    uint private participationFee;
    Car private ownedCar; // 32 digit id;
    ProposedCar private proposedCar;
    ProposedRepurchase private proposedRepurchase;
    ProposedTaxiDriver private proposedTaxiDriver;
    uint private lastDivisionOfProfitTimestamp; // to hold last calling of payDividend() function
    
    address[] private participantArray; 
    
    // participationFee should be changed
    constructor(address managerAddress) {
        fixedExpenses = 10 ether; //
        participationFee = 100 ether;
        manager = managerAddress;
        lastDivisionOfProfitTimestamp = block.timestamp;
    }
    
    function join() public payable checkIsParticipantPayFee() isParticipantNotJoinedAlready() isMaxParticipantNotOver() returns (string memory) {
        participants[msg.sender] = 0 ether;
        participantArray.push(msg.sender);
        contractBalance += msg.value;
        
        return "Successfull";
    }
    
    function setCarDealer(address carDealer_) public isCallerManager() returns (address)
    { 
        carDealer = carDealer_;
        return carDealer;
    }
    
    // example parameter: 12345678912345678912345678912345, 10000000000000000000, 180
    function carProposeToBusiness( uint carID_, uint price_, uint offeredValidTime_) public isCallerCarDealer() isValidCarID(carID_) returns (string memory message) {
        delete proposedCar;
        proposedCar.carID =  carID_ ;
        proposedCar.price =  price_ ;
        proposedCar.offerValidTime = block.timestamp + offeredValidTime_; 
        return ("Car Proposed Successfull");
    }
    
    function approvePurchaseCar() public isCallerParticipant() isParticipantApprovedBeforeForProposedCar() isProposedCarNotEmpty() returns (string memory message){
        proposedCar.approvalState += 1;
        proposedCar.approvedParticipantsForProposedCar.push(msg.sender);
        return ("Approved Successfull");
    }
    
    function purchaseCar() public 
            isCallerManager() 
            isOwnedCarEmpty() // if ownedCar is not empty, it should be repurchased first
            isProposedCarNotEmpty()
            isValueMoreThanOrEqual(proposedCar.offerValidTime-1, block.timestamp) 
            isApprovalStateApprovedMoreThanHalfOfParticipantForProposedCar() 
            isValueMoreThanOrEqual(contractBalance, proposedCar.price) returns (string memory message){
                
        if(!payable(carDealer).send(proposedCar.price)){
            contractBalance -= proposedCar.price;
        }
        
        ownedCar.carID = proposedCar.carID;
        ownedCar.lastExpansesTimestamp = block.timestamp;
        return ("Purchase of car Successfull");
    }
    
     // example parameter: 20000000000000000000, 120 - (20 ether, 2 minute)
    function repurchaseCarPropose( uint price_, uint offeredValidTime_) public isCallerCarDealer() isOwnedCarNotEmpty() returns (string memory message) {
        
        delete proposedRepurchase;
        proposedRepurchase.ownedCarID =  ownedCar.carID;
        proposedRepurchase.price =  price_ ;
        proposedRepurchase.offerValidTime = block.timestamp + offeredValidTime_; 
        
        return ("Repurchase Car Proposed Successfull");
    }
    
    function approveSellProposal() public isCallerParticipant() isParticipantApprovedBeforeForProposedRepurchase() isProposedRepurchaseNotEmpty() returns (string memory message) {
        proposedRepurchase.approvalState += 1;
        proposedRepurchase.approvedParticipantsForProposedRepurchase.push(msg.sender);
        return ("Approved Successfull");
    }
    
    function repurchasecar() public payable
            isCallerCarDealer() 
            isCallerPayRepurchasedCarPrice()
            isValueMoreThan(proposedRepurchase.offerValidTime, block.timestamp) // TO CHECK DOES OFFER TIME STILL VALID
            isApprovalStateApprovedMoreThanHalfOfParticipantForProposedRepurchase() 
            isProposedRepurchaseNotEmpty() 
            isOwnedCarNotEmpty() returns (string memory message){
        
        contractBalance += msg.value;
        
        // to set the car empty
        delete ownedCar;
        
        return ("Repurchase of car Successfull");
    }
    
    // salary: 20000000000000000000
    function proposeDriver(address proposedDriverAddress_, uint salary_) public isCallerManager() isOwnedCarNotEmpty() returns (string memory message) {
        delete proposedTaxiDriver;
        proposedTaxiDriver.driverAddress = proposedDriverAddress_;
        proposedTaxiDriver.salary = salary_;
        return ("Propose Driver Successfull");
    }
    
    function approveDriver() public isCallerParticipant() isParticipantApprovedBeforeForProposedTaxiDriver() isProposedTaxiDriverNotEmpty() returns (string memory message) {
        proposedTaxiDriver.approvalState += 1;
        proposedTaxiDriver.approvedParticipantsForProposedTaxiDriver.push(msg.sender);
        return ("Approved Successfull");
    }
    
    function setDriver() public
            isCallerManager()
            isTaxiDriverEmpty()
            isApprovalStateApprovedMoreThanHalfOfParticipantForTaxiDriver()
            isProposedTaxiDriverNotEmpty() returns (string memory message){
        
        taxiDriver.driverAddress = payable(proposedTaxiDriver.driverAddress);
        taxiDriver.salary = proposedTaxiDriver.salary;
        
        return ("Repurchase of car Successfull");
    }
     
    function fireDriver() public
            isTaxiDriverNotEmpty()
            isCallerManager()
            isValueMoreThanOrEqual(contractBalance, taxiDriver.salary)
            paySalaryOfInitialMonth() returns (string memory message) { 
        
        if(taxiDriver.driverBalance > 0){
            if(!taxiDriver.driverAddress.send(taxiDriver.driverBalance)){
                contractBalance -= taxiDriver.driverBalance;
            }
        }
        
        delete taxiDriver;
		return ("Firing is Successfull");
    }
    
    function payTaxiCharge() public payable isTaxiDriverNotEmpty() isCustomerPayTicket() returns (string memory message) {
        contractBalance += msg.value;
		return ("Paying is successfull");
    }
    
    function releaseSalary() public payable isCallerManager() isTaxiDriverNotEmpty() paySalaryOfInitialMonth() returns (string memory message)  {
        
		return ("Paying salary is successfull");
    }
    
    function getSalary() public payable 
            isCallerTaxiDriver() 
            isValueMoreThan(taxiDriver.driverBalance, 0) returns (string memory message) {
        
        if(!taxiDriver.driverAddress.send(taxiDriver.driverBalance)){
            taxiDriver.driverBalance = 0;
        }
        
		return ("Getting salary is successfull");
    }
    
    function payCarExpenses() public payable 
            isCallerManager() 
            isValueMoreThanOrEqual((block.timestamp - ownedCar.lastExpansesTimestamp) / (60 * 60 * 24 * 7 * 4), 6) 
            isValueMoreThanOrEqual(contractBalance, fixedExpenses) returns (string memory message) {
        
        if(!payable(carDealer).send(fixedExpenses)){
            contractBalance -= fixedExpenses; 
            ownedCar.lastExpansesTimestamp = block.timestamp;
        }
		return ("Paying expenses is successfull");
    }
    
    function payDividend() public payable 
            isCallerManager()
            isValueMoreThan(6, (block.timestamp - ownedCar.lastExpansesTimestamp) / (60 * 60 * 24 * 7 * 4)) // to check that expenses is payed
            isValueMoreThanOrEqual((block.timestamp - lastDivisionOfProfitTimestamp) / (60 * 60 * 24 * 7 * 4) , 6) returns (string memory message) {
        
        uint netProfit = calculateNetProfit();
        uint netIncomePerParticipant = netProfit / participantArray.length;
        if(contractBalance < netProfit){
            revert("The balance is not enough to pay dividend");
        }
        addNetIncomeToEachParticipantsBalances(netIncomePerParticipant);
        contractBalance -= netProfit;
        lastDivisionOfProfitTimestamp = block.timestamp;
		return ("Pay dividend successfully");
    }
    
    function getDividend() public
            isCallerParticipant() 
            isMoneyExistInParticipantBalance() returns (string memory message) {
                
        if(!payable(msg.sender).send(participants[msg.sender])){
            contractBalance -= participants[msg.sender];
            participants[msg.sender] = 0;
        }
        
		return ("Get dividend successfully");
    }
    
    function calculateNetProfit() private view returns (uint) {
        
        bool isExpansesNotPayed = 5 < (block.timestamp - ownedCar.lastExpansesTimestamp) / (60 * 60 * 24 * 7 * 4);
        uint netIncome = contractBalance;
        netIncome -= taxiDriver.driverBalance;
        
        if( isExpansesNotPayed ){
            netIncome -= fixedExpenses;
        }
        return (netIncome);
    }
    
    function addNetIncomeToEachParticipantsBalances(uint netIncomePerParticipant) private {
        for(uint i=0;i<participantArray.length;i++){
            participants[participantArray[i]] += netIncomePerParticipant;
        }
        
    }
     
    
    fallback () external {
        revert();
    }
    
    
    //**************************************** Modifiers ****************************************//
    
    modifier checkIsParticipantPayFee () {
        
        if (msg.value == participationFee) { 
            _ ;
        } 
        else {
            revert("The participant should pay the fee");
        }
    }
    
    modifier isMaxParticipantNotOver() {
        
        if (participantArray.length < 10) { 
            _ ;
        } 
        else {
            revert("The max participant is overed");
        }
    }
    
    modifier isCallerManager() {
        if(manager == msg.sender){
            _;
        } 
        else {
            revert("This function should be called by manager");
        }
    }
    
    modifier isCallerCarDealer(){
        if(carDealer == msg.sender){
            _;
        } 
        else {
            revert("This function should be called by car dealer");
        }
    }
    
    modifier isCallerParticipant(){
        bool isCaller=false;
        for(uint i=0;i<participantArray.length;i++){
            if(participantArray[i]==msg.sender){
                isCaller = true;
                _;
            }
        }
        if(!isCaller){
            revert("This function should be called by a participant");
        }
        
    }
    
    modifier isValidCarID(uint carID_){
        if(carID_ >= 10000000000000000000000000000000 && carID_ <= 99999999999999999999999999999999){
            _;
        } else {
            revert("The car ID is not valid");
        }
    }
    
    modifier isParticipantApprovedBeforeForProposedCar(){
    
        for(uint i=0;i < proposedCar.approvedParticipantsForProposedCar.length;i++){
            if(proposedCar.approvedParticipantsForProposedCar[i]==msg.sender){
                revert("The participant approve already");
            }
        }
        _;
        
    }
    
    modifier isParticipantNotJoinedAlready(){
    
        for(uint i=0;i < participantArray.length;i++){
            if(participantArray[i]==msg.sender){
                revert("The participant joined already");
            }
        }
        _;
        
    } 
    
    modifier isOwnedCarEmpty(){
        if(ownedCar.carID == 0){
            _;
        } else {
            revert("The owned car should be empty");
        }
    }
    
    modifier isApprovalStateApprovedMoreThanHalfOfParticipantForProposedCar(){
        if(proposedCar.approvalState >  participantArray.length / 2){
           _; 
        } else {
            revert("The proposed car should be approved more than half of participant");
        }
    }
    
    modifier isValueMoreThanOrEqual(uint leftValue, uint rightValue){
        if(leftValue >= rightValue){
           _; 
        } else{
            revert("The left parameter should be bigger than or equal to right parameter");
        }
    }
    
    modifier isProposedCarNotEmpty(){
        if(proposedCar.carID != 0){
            _;
        } else{
            revert("The proposed car should not be empty");
        }
    }
    
    modifier isParticipantApprovedBeforeForProposedRepurchase(){
      
        for(uint i=0;i < proposedRepurchase.approvedParticipantsForProposedRepurchase.length;i++){
            if(proposedRepurchase.approvedParticipantsForProposedRepurchase[i]==msg.sender){
                revert("The participant approved before");
            }
        }
        _;
    }
    
    modifier isOwnedCarNotEmpty(){
        if(ownedCar.carID != 0){
            _;
        } else{
            revert("The owned car should not be empty");
        }
    }
    
    modifier isProposedRepurchaseNotEmpty(){
        if(proposedRepurchase.ownedCarID != 0){
            _;
        } else{
            revert("The proposed repurchase should not be empty");
        }
    }
    
    modifier isApprovalStateApprovedMoreThanHalfOfParticipantForProposedRepurchase(){
        if(proposedRepurchase.approvalState >  participantArray.length / 2){
           _; 
        } else {
            revert("The proposed repurchase should be approved more than half of participant");
        }
    }
    
    modifier isCallerPayRepurchasedCarPrice(){
        if(proposedRepurchase.price == msg.value){
            _;
        } else{
            revert("The caller should pay repurchased car price");
        }
    }
    
    modifier isParticipantApprovedBeforeForProposedTaxiDriver(){
        
        for(uint i=0;i < proposedTaxiDriver.approvedParticipantsForProposedTaxiDriver.length;i++){
            if(proposedTaxiDriver.approvedParticipantsForProposedTaxiDriver[i]==msg.sender){
                revert("The participant approved before");
            }
        }
        _;
    }
    
    modifier isProposedTaxiDriverNotEmpty(){
        
        if(proposedTaxiDriver.driverAddress != address(0)){
            _;
        } else{
            revert("The proposed taxi driver cannot be empty");
        }
    }
    
    modifier isApprovalStateApprovedMoreThanHalfOfParticipantForTaxiDriver(){
        
        if(proposedTaxiDriver.approvalState > participantArray.length / 2){
           _; 
        } else{
            revert("The taxi driver should be approved more than half of participant");
        }
    } 
    
    modifier paySalaryOfInitialMonth(){
        
        uint howManyMonthPassedFromLastPayedMonth = (block.timestamp - taxiDriver.timestampOfLastPayedMonth) / (60 * 60 * 24 * 7 * 4);
        if(howManyMonthPassedFromLastPayedMonth != 0 ) { // payment of this month is not processed, if it equals 1, the latest payment is in last 1 month before etc.
            taxiDriver.driverBalance += taxiDriver.salary;
            contractBalance -= taxiDriver.salary;
            taxiDriver.timestampOfLastPayedMonth = block.timestamp;
        }
        _;
    }
    
    modifier isTaxiDriverEmpty(){
        if(taxiDriver.driverAddress == address(0)){
            _;
        } else{
            revert("The taxi driver should be empty");
        }
    }
    
    modifier isTaxiDriverNotEmpty(){
        if(taxiDriver.driverAddress != address(0)){
            _;
        } else{
            revert("The taxi driver cannot be empty");
        }
    }
    
    modifier isCustomerPayTicket(){
        
        if(msg.value > 0){
            _;
        } else{
            revert("The customer should pay the ticket");
        }
    }
    
    modifier isCallerTaxiDriver(){
        
        if(msg.sender == taxiDriver.driverAddress){
            _;
        } else{
            revert("The caller should be the taxi driver");
        }
    }
    modifier isMoneyExistInParticipantBalance(){
        
        if(participants[msg.sender] > 0){
            _;
        } else{
            revert("The balance of the participant equals to zero");
        }
    }
    
    modifier isValueMoreThan(uint leftValue, uint rightValue){
        if(leftValue > rightValue){
           _; 
        } else{
            revert("The left parameter should be more than right parameter");
        }
    }
}