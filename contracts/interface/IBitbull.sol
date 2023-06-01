// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IBitbull {
    function buy(string memory _ref, string memory _slug, address _paymentToken, uint256 _paymentAmount ) external payable returns (uint256);
}