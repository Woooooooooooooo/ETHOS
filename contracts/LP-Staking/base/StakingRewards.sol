// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BaseParam.sol";

abstract contract StakingRewards is ReentrancyGuard, BaseParam, Ownable{

    /* ========== STATE VARIABLES ========== */
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 30000;
    uint256 private _oldRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public jackpot;

    mapping(address => uint256) public payed;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function _sendReward(address to, uint amount, bool isbonus) internal virtual;
    function _swapV2Rate(uint baseRate_) internal view virtual returns(uint);

    /* ========== MODIFIERS ========== */

     modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        uint oldTotal = _totalSupply;

        _;

        uint newRate = _swapV2Rate(rewardRate);
        uint newTotal = _totalSupply;
        if (oldTotal == newTotal && _oldRate == newRate) {
            return;
        }
        if (periodFinish == 0) {
            // jackpot / (newRate / 365 days / _baseProportion * newTotal)
            periodFinish = jackpot * 365 days * _baseProportion / newTotal / newRate + block.timestamp;
        } else if (periodFinish > block.timestamp && newTotal == 0) {
            jackpot = (periodFinish - block.timestamp) * _oldRate * oldTotal / 365 days / _baseProportion;
            periodFinish = 0;
        } else  if (periodFinish > block.timestamp) {
            periodFinish = (periodFinish - block.timestamp) * _oldRate * oldTotal  / newRate / newTotal + block.timestamp;
        }
        _oldRate = newRate;
    }



    /* ========== EVENTS ========== */

    event RewardRateUpdate(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

    /* ========== VIEWS ========== */

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return periodFinish == 0 || block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored + ((lastTimeRewardApplicable() - lastUpdateTime) * 1e18 * _swapV2Rate(rewardRate) / _baseProportion / 365 days);
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
    }
    

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _residue() internal view returns(uint) {
        if (periodFinish > 0 && periodFinish < block.timestamp) {
            return 0;
        }
        return periodFinish == 0 ? jackpot : (periodFinish - block.timestamp) * _oldRate * _totalSupply / 365 days / _baseProportion;
    }

    function _stake(uint256 amount) internal nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Staked(msg.sender, amount);
    }

    function _withdraw(uint256 amount) internal nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender){
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            payed[msg.sender] += reward;
            _sendReward(msg.sender, reward, true);
            emit RewardPaid(msg.sender, reward);
        }
    }


    function updateRewardRate(uint rewardRate_) external updateReward(address(0)) onlyOwner {
        rewardRate = rewardRate_;
    }

    function updateJackpot(uint jackpot_) external onlyOwner {
        if (periodFinish == 0) {
            jackpot += jackpot_;
        } else {
            periodFinish += jackpot_ * 365 days * _baseProportion / _totalSupply / _oldRate;
        }
    }

    
}