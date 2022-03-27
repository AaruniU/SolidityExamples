// SPDX-License-Identifier: MIT
// Barebones implementation of https://www.youtube.com/watch?v=tfk25O-5Ppg

pragma solidity 0.8.10;

contract AccessControl
{
    //Holds roles
    mapping (address => string) public roles;

    constructor()
    {
        //Deploying address becomes ADMIN
        roles [msg.sender] = "ADMIN";
    }

    function GrantRole(address account, string memory role) public 
    {
        //Only an ADMIN or PEASANT can update roles
        require(keccak256(bytes(role)) == keccak256("ADMIN") || keccak256(bytes(role)) == keccak256("PEASANT"));
        roles[account] = role;
    }

    function RevokeRole(address account) public
    {
        roles[account] = "REVOKED";
    }
}
