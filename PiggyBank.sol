// SPDX-License-Identifier: MIT
// My implementation of https://www.youtube.com/watch?v=Geio70-SfSE

// Rules
// Any one can deposit Ether
// Only Owner can withdraw Ether
// The withdrawal will withdraw all Ether at once
// Contract is destroyed once Ether is withdrawn

// How to run
// 1. Deploy owner and fund with 500 wei
// 2. Invoke fundPiggyBank() to deposit 10 wei and get the address of PiggyBank (0xD9eC9E840Bb5Df076DBbb488d01485058f421e58 in my case)
// 3. Load the PiggyBank instance at 0xD9eC9E840Bb5Df076DBbb488d01485058f421e58 using Remix's "At Address" option on the "Deploy and Run transactions" page.
// 3.1 Invoke tellBalance(). It should return 10 wei.
// 4. Deploy the Stranger contract and fund with 500 wei
// 4.1 Invoke fundPiggyBank() which will deplosit 100 wei to PiggyBank at 0xD9eC9E840Bb5Df076DBbb488d01485058f421e58
// 5. Invoke tellBalance() on PiggyBank. It should return 110.
// 6. Invoke breakPiggyBank() on Owner contract.
// 7. Check balance of Owner contract. The new balance should be 490 + 110 = 600 wei.
// 8. Invoke tellBalance() from PiggyBank contract. It should return 0 as the contract's instance has been deleted. 

pragma solidity 0.8.10;

contract PiggyBank
{
    address owner;
    
    constructor()
    {
        owner = msg.sender;
    }
    
    // Anyone can deposit
    function deposit() payable external {}

    function breakPiggyBank() external
    {
        // Only owner can break their PiggyBank
        require(owner == msg.sender, "Only owner can withdraw");
        
        // Delete this contract and send all ether to the caller (owner)
        selfdestruct(payable(msg.sender));
    }

    function tellBalance() external view returns (uint)
    {
        return address(this).balance;
    } 
}

contract Owner
{
    PiggyBank pb;
    
    //Owner will need to have some Ether when first deployed
    constructor() payable
    {
        pb = new PiggyBank();
    }
    
    function fundPiggyBank() external returns (address)
    {
        pb.deposit{value:10} ();
        return address(pb);
    }

    function breakPiggyBank() external
    {
        pb.breakPiggyBank();
    }

    function tellBalance() external view returns (uint)
    {
        return address(this).balance;
    }
}

contract Stranger
{
    PiggyBank pb;

    //Stranger will need to have some Ether when first deployed
    constructor() payable {}

    function fundPiggyBank(address piggyBankAddr) external
    {
        pb = PiggyBank(piggyBankAddr);
        pb.deposit{value:100} ();
    }

    function tellBalance() external view returns (uint)
    {
        return address(this).balance;
    }
}
