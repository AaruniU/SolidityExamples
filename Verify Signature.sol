// SPDX-License-Identifier: MIT
// My implementation of https://www.youtube.com/watch?v=vYwYe-Gv_XI

pragma solidity 0.8.7;

contract VerifySignature
{
    function Verify(address signer, string calldata message, bytes memory signature) external pure returns (bool)
    {
        //We don't sign the message directly
        bytes32 hashPass1 = keccak256(abi.encodePacked(message));
        
        //We need to hash one more time
        bytes32 hashPass2 = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashPass1));

        //ecrecover() needs the signature to be split into r, s and v
        bytes32 r; 
        bytes32 s; 
        uint8 v;
        assembly
        {
            r := mload(add(signature, 32)) //skip 32 bytes and load the next 32 bytes (same as size of r)
            s := mload(add(signature, 64)) //skip (32 + 32) bytes and load the next 32 bytes (same as size of s)
            v := byte(0, mload(add(signature, 96)))
        }

        //Return true if address returned by ecrecover() is same as the signer
        return ecrecover(hashPass2, v, r, s) == signer;
    }
}
