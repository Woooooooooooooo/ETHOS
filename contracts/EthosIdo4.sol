// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IBitbull.sol";

contract EthosIdo4 is Ownable{

    event Log(address indexed account, uint time, uint indexed amount, string ref);

    struct InvestLog{
        address account;
        uint time;
        uint amount;
        string ref;
    }

    struct thawInfo{
        uint256 date;       //释放时间
        uint256 proportion; //释放比例万分之几
    }

    struct Info{
        uint targetAmount;
        uint totalAmount;
        uint min;
        uint max;
        uint price;
        uint decimalPlace;
        uint startTime;
        uint endTime;
        IERC20 inputToken;
        IERC20 outputToken;
    }
    
    uint private _accumulate;
    IBitbull public bitbull;
    Info private _info;
    address private _receiver;
    mapping(address => uint) investment;
    mapping(address => uint) kol;
    InvestLog[] investLogs;
    
    thawInfo[] private _thawInfoList;

    constructor(Info memory info_, address receiver) {
        _info = info_;
        _receiver = receiver;
    }

    function editBitbull(IBitbull bitbull_) external onlyOwner(){
        bitbull = bitbull_;
        _info.inputToken.approve(address(bitbull), type(uint).max);
    }

    function info() external view returns(Info memory, uint) {
        return (_info, _accumulate);
    }

    function exportInvestLog(uint start, uint end) external view onlyOwner() returns(InvestLog[] memory){
        InvestLog[] memory investLog_ = new InvestLog[](end - start);
        for(uint i = start; i < end; i++) {
            investLog_[i - start] = investLogs[i];
        }
        return investLog_;
    }

    function getInvestLog(address account) external view returns(InvestLog[] memory log) {
        for (uint i; i < investLogs.length; i++) {
            if (investLogs[i].account == account) {
               log = listPush(log, investLogs[i]);
            }
        }
    }

    function listPush(InvestLog[] memory investLogs_, InvestLog memory investLog_) internal pure returns(InvestLog[] memory) {
        InvestLog[] memory logs = new InvestLog[](investLogs_.length + 1);
        logs[investLogs_.length] = investLog_;
        for (uint i; i < investLogs_.length; i++) {
            logs[i] = investLogs_[i];
        }
        return logs;
    }

    function invest(uint amount, string memory ref, string memory slug) external {
        Info memory info_ = _info;
        require(info_.startTime <= block.timestamp && block.timestamp <= info_.endTime, "is end");
        require(info_.min <= amount && amount <= info_.max ,"min<=amount<=max");
        require(info_.totalAmount == 0 || _accumulate < info_.totalAmount, "is end");
        if (bytes(ref).length > 0) {
            kol[msg.sender] = 1;
            SafeERC20.safeTransferFrom(_info.inputToken, msg.sender, address(this), amount);
            bitbull.buy(ref, slug, address(_info.inputToken), amount);
        } else {
            SafeERC20.safeTransferFrom(_info.inputToken, msg.sender, _receiver, amount);
        }
        investment[msg.sender] += amount;
        _accumulate += amount;
        investLogs.push(InvestLog(msg.sender, block.timestamp, amount, ref));
        emit Log(msg.sender, block.timestamp, amount, ref);
    }


}


