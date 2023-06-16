// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)
import '@openzeppelin/contracts/utils/cryptography/EIP712.sol';

pragma solidity ^0.8.0;

contract T712 is EIP712{

    constructor() EIP712('712', '1.0') {

    }

    function verify(address from,address to, string memory contents, bytes memory signature) external view returns(address) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Mail(address from,address to,string contents)"),
        from,
        to,
        keccak256(bytes(contents))
        )));
        address signer = ECDSA.recover(digest, signature);
        return signer;
    }

 }
