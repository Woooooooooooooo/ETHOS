// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.12 <0.9.0;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interface/IEthosMiner.sol";

contract EthosNFTDisplace{

    using Address for address;

    struct Info{
        IERC721Enumerable input;
        IEthosMiner output;
    }

    Info public info;
   
    constructor(IERC721Enumerable input, IEthosMiner output) {
        info.input = input;
        info.output = output;
    }

    function displace(uint tokenId) external {
        require(!msg.sender.isContract());
        info.input.transferFrom(msg.sender, address(this), tokenId);
        uint character_ = 10 - ((_random(20) + 19) / 20 * 5 + _random(5));
        info.output.mint(msg.sender, character_);
    }

    function _random(uint number) internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number;
    }

    function nftList(address account) external view returns(uint[] memory tokenIds) {
        for (uint i = 0; i < IERC721Enumerable(info.output).balanceOf(account); i++) {
            tokenIds = listPush(tokenIds, IERC721Enumerable(info.output).tokenOfOwnerByIndex(account, i));
        }
    }
    
    function listPush(uint[] memory tokenIds, uint tokenId) internal pure returns(uint[] memory) {
        uint[] memory result = new uint[](tokenIds.length + 1);
        result[tokenIds.length] = tokenId;
        for (uint i; i < tokenIds.length; i++) {
            result[i] = tokenIds[i];
        }
        return result;
    }

}