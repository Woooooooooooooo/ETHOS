// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IEthosMiner is IERC721Enumerable{
    function mint(address to, uint character_) external;
}