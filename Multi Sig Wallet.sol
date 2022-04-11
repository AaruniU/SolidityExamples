// SPDX-License-Identifier: MIT
// My implementation of https://solidity-by-example.org/app/multi-sig-wallet/
// **Not tested**
// In a Multi Signature Wallet:
//      We have to declare owners when deploying the contract
//      Any of these owners can submit a transaction to be executed
//      A certain number of these owners have to confirm these transactions before they can be executed
//      Owners can rovoke confirmation before a transaction is executed
//      Any one can deposit funds to this wallet

pragma solidity 0.8.10;

contract MultiSigWallet
{
    uint numOfConfirmations;
    
    mapping (address => bool) public isOwner ;
    mapping (uint => mapping(address => bool)) public isConfirmed;

    struct Transaction
    {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numOfConfirmations;
    }

    Transaction[] public transactions;

    modifier onlyOwner()
    {
        require (isOwner[msg.sender], "Not owner");
        _;
    }

    modifier notExecuted(uint txnIndex)
    {
        require (!transactions[txnIndex].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint txnIndex)
    {
        require (transactions[txnIndex].numOfConfirmations < numOfConfirmations, "Transaction already confirmed");
        require (!isConfirmed[txnIndex][msg.sender], "Transaction already confirmed");
        _;
    }

    modifier txnExists(uint txnIndex) 
    {
        require (txnIndex < transactions.length, "Invalid transaction");
        _;
    }
    
    constructor (address[] memory owners, uint _numOfConfirmations)
    {
        for(uint i = 0; i < owners.length; i++)
        {
            isOwner[owners[i]] = true;
        }

        numOfConfirmations = _numOfConfirmations;
    }

    // Accept incoming ether
    receive() external payable{}

    function submitTransaction(address _to,  uint value, bytes memory data, bool executed, uint _numOfConfirmations) public onlyOwner
    {
        transactions.push(Transaction(_to, value, data, executed, _numOfConfirmations));
    }

    function confirmTransaction(uint txnIndex) public onlyOwner notExecuted(txnIndex) notConfirmed(txnIndex) txnExists(txnIndex)
    {
        transactions[txnIndex].numOfConfirmations++;
        isConfirmed[txnIndex][msg.sender] = true;
    }

    function executeTransaction(uint txnIndex) public onlyOwner notExecuted(txnIndex) txnExists(txnIndex)
    {
        Transaction memory t = transactions[txnIndex];
        require(t.numOfConfirmations == numOfConfirmations, "Transaction not confirmed yet"); 
        (bool result, ) = t.to.call{value: t.value}(t.data); // Run the transaction
        t.executed = result;
        require (result, "Transaction failed");
    }

    function revokeConfirmation(uint txnIndex) public onlyOwner notExecuted(txnIndex) txnExists(txnIndex)
    {
        isConfirmed[txnIndex][msg.sender] = false;
        transactions[txnIndex].numOfConfirmations--;
    }
}
