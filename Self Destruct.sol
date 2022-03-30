// SPDX-License-Identifier: MIT
// My implementation of https://www.youtube.com/watch?v=ajCsPRl5S3Q
// Demonstrates selfdestruct()

pragma solidity 0.8.10;

// Send this contract some Ether while deploying
contract KillMe
{
    // Make payable to send ether during deployment
    constructor() payable {}
    
    function KillMeNow() external
    {
        // make sender address payable to surrender all Ether after selfdestruct
        selfdestruct(payable(msg.sender));
    }

    // Check balance before selfdestruct()
    function GetBalance() external view returns (uint)
    {
        return address(this).balance;
    }
}

contract Killer
{
    // Pass the address of KillMe contract
    function HitMan(address a) external
    {
        KillMe(a).KillMeNow();
    }

    // Check balance after calling selfdestruct()
    function GetBalance() external view returns (uint)
    {
        return address(this).balance;
    }
}
