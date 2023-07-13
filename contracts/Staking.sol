// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract Staking is Ownable{

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    mapping(uint => uint) public categoryTotal;
    EnumerableMap.UintToUintMap private _production;
    mapping(address => uint) public userLastTime;
    mapping(address => EnumerableSet.UintSet) private _staked;
    mapping(address => mapping(uint => uint)) public categoryStaked;
    mapping(address => mapping(uint => uint)) public categoryStakedBonus;
    mapping(address => mapping(uint => uint)) public categoryStakedBonusPayed;
    Info public info;

    struct Info {
        IERC20 erc20;
        IERC721Metadata erc721;
    }

    modifier update() {
        if (userLastTime[msg.sender] != block.timestamp) {
            for (uint i; i < _production.length(); i++) {
                (uint k, uint v) = _production.at(i);
                if (categoryStaked[msg.sender][k] == 0) continue;
                categoryStakedBonus[msg.sender][k] = earned(msg.sender, k);
            }
            userLastTime[msg.sender] = block.timestamp;
        }
        _;
    }

    constructor(IERC20 erc20, IERC721Metadata erc721) {
        info.erc20 = erc20;
        info.erc721 = erc721;
    }

    function earned(address account, uint category) public view returns (uint256) {
        return categoryStakedBonus[account][category] + categoryStaked[account][category] * (block.timestamp - userLastTime[account]) * _production.get(category);
    }

    struct SetProduction {
        uint category;
        uint productionDay;
    }

    function setProductionDay(SetProduction[] calldata productions) external onlyOwner(){
        for(uint i; i < productions.length; i++){
            _production.set(productions[i].category, productions[i].productionDay / 1 days);
        }
    }

    function removeProduction(uint[] calldata categorys) external onlyOwner(){
        for(uint i; i < categorys.length; i++){
            _production.remove(categorys[i]);
        }
    }


    function rangeCategoryTotal(uint[] calldata categorys) external view returns (uint total_){
        for (uint i; i < categorys.length; i++) {
            total_ += categoryTotal[categorys[i]];
        }
    }

    function stake(uint tokenId) public update {
        info.erc721.transferFrom(msg.sender, address(this), tokenId);
        uint category = _stringToUint(_substr(info.erc721.tokenURI(tokenId), 26, 3));
        categoryTotal[category] += 1;
        categoryStaked[msg.sender][category] += 1;
        _staked[msg.sender].add(tokenId);
    }

    function stakeBatch(uint[] calldata tokenIds) external {
        for (uint i; i < tokenIds.length; i++) {
            stake(tokenIds[i]);
        }
    }

    function withdraw(uint tokenId) public update {
        require(_staked[msg.sender].contains(tokenId), 'tokenId error');
        info.erc721.transferFrom(address(this), msg.sender, tokenId);
        uint category = _stringToUint(_substr(info.erc721.tokenURI(tokenId), 26, 3));
        categoryTotal[category] -= 1;
        categoryStaked[msg.sender][category] -= 1;
        _staked[msg.sender].remove(tokenId);
    }

    function withdrawBatch(uint[] calldata tokenIds) external {
        for (uint i; i < tokenIds.length; i++) {
            withdraw(tokenIds[i]);
        }
    }

    function harvest(uint[] calldata categorys) external update {
        uint bonus;
        for(uint i; i < categorys.length; i++){
           bonus += categoryStakedBonus[msg.sender][categorys[i]];
           categoryStakedBonusPayed[msg.sender][categorys[i]] += categoryStakedBonus[msg.sender][categorys[i]];
           categoryStakedBonus[msg.sender][categorys[i]] = 0;
        }
        if (bonus > 0) info.erc20.transfer(msg.sender, bonus);
    }

    function stakingList(address account, uint[] calldata categorys) external view returns(uint[] memory) {
        uint length = info.erc721.balanceOf(account);
        if (length == 0 || categorys.length == 0) {
            return new uint[](1);
        }
        uint tokenId; uint category; uint k;
        uint[] memory tokenIds = new uint[](length);
        for (uint i; i < length; i++) {
            tokenId = IERC721Enumerable(address(info.erc721)).tokenOfOwnerByIndex(account, i);
            category = _stringToUint(_substr(info.erc721.tokenURI(tokenId), 26, 3));
            for (uint j; j < categorys.length; j++) {
                if (categorys[j] == category) {
                    tokenIds[k] = tokenId;
                    k++;
                }
            }
        }
        return tokenIds;
    }

    function withdrawList(address account, uint[] calldata categorys) external view returns(uint[] memory) {
        uint length = _staked[account].length();
        if (length == 0 || categorys.length == 0) {
            return new uint[](1);
        }
        uint tokenId; uint category; uint k;
        uint[] memory tokenIds = new uint[](length);
        for (uint i; i < length; i++) {
            tokenId = _staked[account].at(i);
            category = _stringToUint(_substr(info.erc721.tokenURI(tokenId), 26, 3));
            for (uint j; j < categorys.length; j++) {
                if (categorys[j] == category) {
                    tokenIds[k] = tokenId;
                    k++;
                }
            }
        }
        return tokenIds;
    }

    struct DataView {
        uint totalStaked;
        uint yourStaked;
        uint earned;
        uint harvested;
    }

    function dataView(address account, uint[] calldata categorys) external view returns (DataView memory dataView_) {
        for (uint i; i < categorys.length; i++) {
            dataView_.totalStaked += categoryTotal[categorys[i]];
            dataView_.yourStaked += categoryStaked[account][categorys[i]];
            dataView_.earned += earned(account, categorys[i]);
            dataView_.harvested += categoryStakedBonusPayed[account][categorys[i]];
        }
    }

    function _substr(string memory _self, uint _start, uint _len) private pure returns (string memory _ret) {
        if (_len > bytes(_self).length-_start) {
            _len = bytes(_self).length-_start;
        }

        if (_len <= 0) {
            _ret = "";
            return _ret;
        }
        
        _ret = new string(_len);

        uint selfptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        _memcpy(retptr, selfptr+_start, _len);
    }

    function _memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
    
    function _stringToUint(string memory s) private pure returns(uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for(uint i = 0; i < b.length; i++) {
        if(uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
            result = result * 10 + (uint8(b[i]) - 48);
        }
        }
        return result;
    }

}