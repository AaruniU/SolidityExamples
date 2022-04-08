// SPDX-License-Identifier: MIT
// My insecure implementation of an ERC20 token
// https://solidity-by-example.org/app/erc20/
// ** Not Tested **

pragma solidity 0.8.10;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
// We need to implement this interface to create our ERC20 token
interface IERC20 
{
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MyERC20 is IERC20
{
    // Stores addresses and amount of tokens it has
    mapping (address => uint) public _balanceOf;
    
    // Stores spender addresses and amount of tokens they is allowed to spend on bahalf of an owner address
    // owner => (spender => amount)
    mapping (address => mapping (address => uint)) public _allowance;

    // Name of our token
    string public name = "Web 3 Security";

    // Symbol of our token
    string public symbol = "WEB3SEC";

    // Maximum nuber of tokens that exist
    uint public _totalSupply = 100;

    // The number of decimal places allowed
    uint8 public decimals = 18;
    
    function totalSupply() external view returns (uint)
    {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint)
    {
        return _balanceOf[account];
    }

    function transfer(address recipient, uint amount) external returns (bool)
    {
        require (_balanceOf[msg.sender] > amount, "Insufficient balance");
        
        _balanceOf[msg.sender] -= amount;
        _balanceOf[recipient] += amount;
        
        // Let the world know the transfer was successful
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) external view returns (uint)
    {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint amount) external returns (bool)
    {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Allows spender to transfer money on owner's behalf
    function transferFrom(address sender, address recipient, uint amount) external returns (bool)
    {
        require(_allowance[sender][msg.sender] >= amount, "Insufficient allowance");
        require(_balanceOf[sender] >= amount, "Insufficient funds");

        _balanceOf[sender] -= amount;
        _allowance[sender][msg.sender] -= amount;
        _balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Create token out of thin air
    function mint(uint amount) public returns (bool)
    {
        _balanceOf[msg.sender] += amount;
        _totalSupply += amount;

        // address(0) i.e. 0x00 is the thin air
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    // Burn tokens
    function burn(uint amount) public returns (bool)
    {
        _balanceOf[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
