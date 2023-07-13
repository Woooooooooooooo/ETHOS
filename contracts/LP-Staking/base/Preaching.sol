// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./BaseParam.sol";

abstract contract Preaching is BaseParam{

    using EnumerableMap for EnumerableMap.UintToUintMap;

    EnumerableMap.UintToUintMap experience;
    
    struct PInfo {
        uint depth;
        uint[] inviteProportion;
    }

    PInfo public pInfo;
    uint preachReward;

    struct Player{
        uint totalplayer;
        uint rewardInvite;
        uint rewardPayedInvite;
        address referral;
        address[] referrals;
    }

    mapping(address => Player) public players;

    event RewardInvite(address indexed account, uint amount);
    event Binding(address indexed referral, address indexed account, uint time);

    function _sendReward(address to, uint amount, bool isbonus) internal virtual;

    constructor(uint depth_) {
        pInfo.depth = depth_;
        pInfo.inviteProportion.push(1000);
        pInfo.inviteProportion.push(500);
        pInfo.inviteProportion.push(200);
       
    }

    function binding(address referral, address account) external {
        require(referral != address(0) && account != address(0) && referral != account, 'param error');
        require(_repeat(referral, account), 'Referral is duplicated');
        players[account].referral = referral;
        players[referral].referrals.push(account);
        players[referral].totalplayer = players[referral].referrals.length;
        emit Binding(referral, account, block.timestamp);
    }

    function _repeat(address referral, address account) internal view returns (bool) {
        for(uint i = 0; i < pInfo.depth; i++) {
            referral = players[referral].referral;
            if (referral == address(0)) return true; 
            if (referral == account) return false;
        }
        return true;
    }

    function _bonusInvite(uint amount) internal {
        address addr = msg.sender;
        for (uint i; i < pInfo.inviteProportion.length; i++) {
            addr = players[addr].referral;
            if(addr == address(0)) return;
            players[addr].rewardInvite += amount * pInfo.inviteProportion[i] / _baseProportion;
        }
    }

    function getRewardInvite() public {
        uint256 reward = players[msg.sender].rewardInvite;
        if (reward > 0) {
            players[msg.sender].rewardInvite = 0;
            players[msg.sender].rewardPayedInvite += reward;
            preachReward += reward;
            _sendReward(msg.sender, reward, false);
            emit RewardInvite(msg.sender, reward);
        }
    }
}