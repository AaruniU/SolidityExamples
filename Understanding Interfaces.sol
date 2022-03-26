Interfaces can be used in 2 ways in Solidity:

1.	As a way to enforce implementation of some methods. This is similar to how traditional OOP languages use interfaces.

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

// Defines the functions that must be implemented in the child contract 
interface ITest
{
    function foo(uint) external pure returns(bool);
}

contract Test is ITest
{
    //Need to override and implement all functions in the interface
    function foo(uint i) external pure override returns (bool)
    {
        if(i>5) return true;
        else return false;
    }
}

2.	As a way to call an instance of a contract on the blockchain

Suppose we have an instance of contract A, depicted below, deployed on the blockchain. Let’s also assume the source code of this super-secret contract has not been made public and other folks who wish to interact with contract A only know the function name and return type of all functions in this contract. Now the question is how do we invoke the functions in this contract?

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract A
{
    function foo() public pure returns (string memory)
    {
        return "A.foo";
    } 
}

Because the source code is not available, we cannot create a reference to the instance of contract A inside another contract (say B) like this:
contract B
{
    function Call_A() public pure returns (string memory)
    {
        // 0xCf5609B003B2776699eEA1233F7C82D5695cC9AA is the address of contract A's instance on the blockchain
        A a = A(0xCf5609B003B2776699eEA1233F7C82D5695cC9AA);
        return a.foo();
    }
}

Solidity solves this problem by allowing interfaces to be used as a liaison between contract A and B.

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract A
{
    function foo() public pure returns (string memory)
    {
        return "A.foo";
    } 
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IA
{
    //This should match the signature of foo in contract A
    function foo() external pure returns (string memory) ;
}
contract B
{
    function foo() public pure returns (string memory)
    {
        // 0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D is the address of contract A's instance
        IA ia = IA(0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D);
        return ia.foo();
    }
}

Through the interface IA, we are requesting the compiler to let us reference an instance of an unfamiliar contract A with the assurance that the functions declared in the interface exist in the instance as well. What happens if the function in the interface does not exist in Contract A? It will execute the fallback function.

contract B
{
    function foo() public pure returns (string memory)
    {
        // 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c is the address of contract A's instance
        IA ia = IA(0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c);
        
        // Calls the fallback()
        return ia.moo();
    }
}

We can take this a step further and implement interface IA in a new contract “C”. Contract C may also contain new functions of its own, effectively enabling us to create a chid contract of A without having A’s source.

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IA
{
    //This should match the signature of foo in contract A
    function foo() external pure returns (string memory) ;
}

contract C is IA
{
    function foo() public pure override returns (string memory)
    {
        // 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c is the address of contract A's instance
        return IA(0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c).foo();
    }

    function AnotherFunction() public pure
    {
        // Do something here
    }
}

contract D
{
    function test() public returns (string memory)
    {
        (new C()).AnotherFunction();
        return (new C()).foo();
    }
}
