// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import "./base/SwapV2.sol";
import "./base/Preaching.sol";
import "./base/StakingRewards.sol";

contract LPStaking is StakingRewards, Preaching, SwapV2 {
    using SafeERC20 for IERC20;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    struct Info {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint lockTime;
    }

    Info public info;
    mapping(address => uint) stakedTime;

    constructor(
        address stakeToken_,
        address rewardToken_
    ) SwapV2(stakeToken_, rewardToken_) Preaching(3) {
        info.stakeToken = IERC20(stakeToken_);
        info.rewardToken = IERC20(rewardToken_);
        info.lockTime = 31;
    }

    function _swapV2Rate(uint baseRate_) internal view override(StakingRewards, SwapV2) returns(uint) {
        return SwapV2._swapV2Rate(baseRate_);
    }
   
    function _sendReward(
        address to,
        uint amount,
        bool isbonus
    ) internal override(Preaching, StakingRewards) {
        info.rewardToken.safeTransfer(to, amount);
        if (isbonus) _bonusInvite(amount);
    }
    
    function withdrawERC20(IERC20 erc20) external onlyOwner {
        erc20.safeTransfer(msg.sender, erc20.balanceOf(msg.sender));
    }

    function stake(uint256 amount) external {
        info.stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        stakedTime[msg.sender] = block.timestamp;
        StakingRewards._stake(amount);
    }

    function withdraw() external {
        require((block.timestamp - stakedTime[msg.sender]) / 30 days % info.lockTime == 30, "locking");
        info.stakeToken.safeTransfer(msg.sender, balanceOf(msg.sender));
        _withdraw(balanceOf(msg.sender));
    }

    struct ViewHome {
        uint priceLP;
        uint price3TH;
        uint circulatingSupply;
        uint valueOfStaking;
        uint StakingToTarnAPY;
        uint youHaveStaked;
        uint youHaveEarned;
        uint youCanHaverst;
        uint inviteFriendToStakeGetMore3TH;
        uint stakedTime;
    }

    function viewHome(address account) external view returns(ViewHome memory){
        return ViewHome(SwapV2._swapV2Rate(_baseDecimals), SwapV2._unitPrice(_baseDecimals),  _residue(), totalSupply(), StakingRewards.rewardRate, StakingRewards.balanceOf(account), StakingRewards.payed[account], StakingRewards.earned(account), Preaching.players[account].rewardInvite, stakedTime[account]);
    }

}
