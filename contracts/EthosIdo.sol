// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interface/IBitbull.sol";

contract EthosIdo is Ownable{

    using EnumerableSet for EnumerableSet.AddressSet;

    struct ThawInfo{
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
        IERC20Upgradeable inputToken;
        IERC20Upgradeable outputToken;
    }
    
    uint constant private kolProportion = 300;
    uint constant private BASE_PROPORTION = 10000;
    uint private _accumulate;
    uint private _clean;
    IBitbull public bitbull;
    Info private _info;
    mapping(address => uint) public investment;
    mapping(address => uint) payed;
    mapping(address => uint) kol;
    ThawInfo[] private _thawInfoList;
    EnumerableSet.AddressSet private _accounts;

    constructor(Info memory info_, IBitbull bitbull_) {
        _info = info_;
        bitbull = bitbull_;
        SafeERC20Upgradeable.safeApprove(_info.inputToken, address(bitbull_), type(uint).max);
    }

    function setStartTimeAndPrice(uint startTime, uint min) external onlyOwner(){
        _info.startTime = startTime;
        _info.min = min;
    }

    function count() external view returns(uint){
        return _accounts.length();
    }

    function editBitbull(IBitbull bitbull_) external onlyOwner(){
        bitbull = bitbull_;
        SafeERC20Upgradeable.safeApprove(_info.inputToken, address(bitbull_), type(uint).max);
    }

    function info() external view returns(Info memory, uint) {
        return (_info, _accumulate);
    }

    function setThawInfo(ThawInfo[] memory thawInfo) external onlyOwner(){
        delete _thawInfoList;
        for (uint i; i < thawInfo.length; i++) {
            _thawInfoList.push(thawInfo[i]);
        }
    }
    
    function thawInfoList() external view returns(ThawInfo[] memory){
        return _thawInfoList;
    }

    function _getThawProportion(uint256 date) internal view returns(uint256 proportion){
        ThawInfo[] memory thawInfoList_ = _thawInfoList;
        for(uint256 i = 0; i < _thawInfoList.length; i++) {
            if (date >= thawInfoList_[i].date) proportion += thawInfoList_[i].proportion;
        }
    }

    function invest(uint amount, string memory ref, string memory slug) external {
        Info memory info_ = _info;
        require(info_.startTime <= block.timestamp && block.timestamp <= info_.endTime, "is end");
        require(info_.min <= amount && amount <= info_.max ,"min<=amount<=max");
        require(info_.totalAmount == 0 || _accumulate < info_.totalAmount, "is end");
        SafeERC20Upgradeable.safeTransferFrom(_info.inputToken, msg.sender, address(this), amount);
        bitbull.buy(ref, slug, address(_info.inputToken), amount);
        investment[msg.sender] += amount;
        _accumulate += amount;
        kol[msg.sender] = bytes(ref).length;
       //investLog[msg.sender].push(InvestLog(block.timestamp, amount, bytes(ref).length));
        _accounts.add(msg.sender);
    }

    function expected(address account, uint time) public view returns(uint total, uint balance, uint additional){
        uint proportion = _getThawProportion(time);
        // investment[account] / (_info.price / _info.decimalPlace) * (proportion / BASE_PROPORTION);
        total = investment[account] * _info.decimalPlace * proportion / _info.price / BASE_PROPORTION;
        if (kol[account] == 1) 
            additional = total * kolProportion / BASE_PROPORTION;
            total += additional;
        balance = total - payed[account];
    }

    function getRewards() public {
        (, uint256 balance,)= expected(msg.sender, block.timestamp);
        require(balance > 0, "No available balance");
        payed[msg.sender] += balance;
        SafeERC20Upgradeable.safeTransfer(_info.outputToken, msg.sender, balance);
    }

    function withdraw() external onlyOwner(){
        uint input = _info.inputToken.balanceOf(address(this));
        if (input > 0) 
            SafeERC20Upgradeable.safeTransfer(_info.inputToken, msg.sender, input);
        uint output = _info.outputToken.balanceOf(address(this));
        if (output > 0) 
            SafeERC20Upgradeable.safeTransfer(_info.outputToken, msg.sender, output);
    }

    struct ImportLog{
        uint amount;
        uint ref;
        uint payed;
        address account;
    }

    function importInvestLog(ImportLog[] memory importLog) external onlyOwner(){
        for (uint i; i < importLog.length; i++) {
            kol[importLog[i].account] = importLog[i].ref;
            investment[importLog[i].account] = importLog[i].amount;
            payed[importLog[i].account] = importLog[i].payed;
            _accounts.add(importLog[i].account);
        }
    }


    function exportInvestLog(uint start, uint end) external view onlyOwner() returns(ImportLog[] memory log){
        address account;
        for(uint i = start; i < end; i++) {
            account = _accounts.at(i);
            log = listPush(log, ImportLog(investment[account], payed[account], kol[account], account));
        }
    }

    function listPush(ImportLog[] memory importLogs, ImportLog memory importLog_) internal pure returns(ImportLog[] memory) {
        ImportLog[] memory logs = new ImportLog[](importLogs.length + 1);
        logs[importLogs.length] = importLog_;
        for (uint i; i < importLogs.length; i++) {
            logs[i] = importLogs[i];
        }
        return logs;
    }

}


