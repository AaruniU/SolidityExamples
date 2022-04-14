// SPDX-License-Identifier: MIT
// A Croud Funding contract using ERC20 tokens
// My implementation of https://solidity-by-example.org/app/crowd-fund/
// **Not tested**

pragma solidity 0.8.10;

interface IERC20
{
    // We only need to invoke 2 functions on the ERC20 tokens that we are using
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

contract CrowdFund
{
    IERC20 public token;

    struct Campaign
    {
        address owner;
        uint target;
        uint pledged;
        uint32 startDate;
        uint32 endDate;
        bool claimed;
    }

    // Assign an uint ID to Campaigns
    mapping(uint => Campaign) public campaigns;

    // TO track contribution made by an address towards a particular campaign
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    uint campaignCount;

    // Supply the contract address for the ERC20 token that we will accept for pledge
    constructor(IERC20 _token)
    {
        token = _token;
    }

    function launch(uint target, uint32 startDate, uint32 endDate) public
    {
        require(target > 0, "Target should be > 0");
        require(startDate > block.timestamp, "startDate should be in future");
        require(endDate > startDate, "endDate should be > startDate");

        campaigns[campaignCount++] = Campaign(msg.sender, target, 0, startDate, endDate, false);
    }

    function cancel(uint campaignIndex) public
    {
        Campaign memory c = campaigns[campaignIndex];
        
        require(c.owner == msg.sender, "not owner");
        require(c.startDate > block.timestamp, "Campaign started already");

        // Reset the mapping entry
        delete campaigns[campaignIndex];
    }

    function pledge(uint campaignIndex, uint amount) public
    {
        Campaign memory c = campaigns[campaignIndex];

        require(c.startDate <= block.timestamp, "not yet started");
        require(c.endDate > block.timestamp, "campaign ended");

        c.pledged += amount;
        pledgedAmount[campaignIndex][msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function claim(uint campaignIndex) public
    {
        Campaign memory c = campaigns[campaignIndex];

        require(msg.sender == c.owner, "not owner");
        require(!c.claimed, "already claimed");
        require(c.endDate < block.timestamp, "campaign in progress");
        require(c.pledged >= c.target, "pledge target not met yet");

        c.claimed = true;
        // owner is the sender
        token.transfer(msg.sender, c.pledged);
    }

    function unpledge(uint campaignIndex, uint amount) public
    {
        Campaign memory c = campaigns[campaignIndex];

        require(c.endDate > block.timestamp, "campaign ended");
        require(pledgedAmount[campaignIndex][msg.sender] >= amount, "not sufficient amount to withdraw");

        pledgedAmount[campaignIndex][msg.sender] -= amount;
        c.pledged -= amount;
        token.transfer(msg.sender, amount);
    }
}
