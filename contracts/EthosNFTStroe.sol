// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./interface/IEthosNFT.sol";

contract EthosNFTStroe is Ownable{

    using SafeERC20 for IERC20;

    uint public total;
    address private _receiver;
    IERC20 public toekn;
    IEthosNFT public nft;
    Phase public phase;
    mapping(address => LockLog[]) private _locklogs;
    mapping(address => uint) public quantity;

    struct Phase {
        uint startTime;
        uint endTime;
        uint max;
        uint limit;
        uint price;
        uint lockTime;
        bool isLock;
    }

    struct LockLog {
        uint unLockTime;
        uint amount;
    }

    constructor(
        IERC20 toekn_,
        IEthosNFT nft_,
        address receiver,
        Phase memory phase_
    ) {
        phase = phase_;
        toekn = toekn_;
        nft = nft_;
        _receiver = receiver;
    }

    function locklogs(address account) external view returns (LockLog[] memory){
        return _locklogs[account];
    }

    function edit(Phase memory phase_) public onlyOwner {
        phase = phase_;
    }
    

    function mint(address to) external {
        require(phase.max > total, "mint failed");
        require(quantity[to] < phase.limit, "mint failed");
        ++quantity[to];
        ++total;
        if (phase.isLock) {
            toekn.transferFrom(msg.sender, address(this), phase.price);
            _locklogs[msg.sender].push(LockLog(block.timestamp + phase.lockTime, phase.price));
        } else {
            toekn.transferFrom(msg.sender, _receiver, phase.price);
        }
        nft.mint(to);
    }

    function withdraw(uint index) external {
        LockLog memory log = _locklogs[msg.sender][index];
        require(log.amount > 0 && log.unLockTime < block.timestamp, "withdraw error");
        toekn.transfer(msg.sender, log.amount);
        uint length = _locklogs[msg.sender].length;
        if (length - 1 != index && index != 0) {
            LockLog memory temp = _locklogs[msg.sender][index];
            _locklogs[msg.sender][index] = _locklogs[msg.sender][length];
            _locklogs[msg.sender][length] = temp;
        }
        _locklogs[msg.sender].pop();
    }

    function nftList(address account) external view returns(uint[] memory tokenIds) {
        for (uint i = 0; i < nft.balanceOf(account); i++) {
            tokenIds = listPush(tokenIds, nft.tokenOfOwnerByIndex(account, i));
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