// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


import "./interface/IBitbull.sol";

contract EthosIdoBSCcopy is Ownable{

    struct InvestLog{
        uint time;
        uint amount;
        uint ref;
    }

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
        IERC20 inputToken;
        IERC20 outputToken;
    }
    
    uint constant private kolProportion = 300;
    uint constant private BASE_PROPORTION = 10000;
    uint private _accumulate;
    uint private _clean;
    IBitbull public bitbull;
    Info private _info;
    mapping(address => uint) investment;
    mapping(address => uint) payed;
    mapping(address => uint) kol;
    mapping(address => InvestLog[]) investLog;
    ThawInfo[] private _thawInfoList;
    address[] private _accounts;
    

    constructor(Info memory info_, IBitbull bitbull_) {
        _info = info_;
        bitbull = bitbull_;
        _info.inputToken.approve(address(bitbull_), type(uint).max);
    }

    function setStartTimeAndPrice(uint startTime, uint min) external onlyOwner(){
        _info.startTime = startTime;
        _info.min = min;
    }

    function count() external view returns(uint){
        return _accounts.length;
    }

    function editBitbull(IBitbull bitbull_) external onlyOwner(){
        bitbull = bitbull_;
        _info.inputToken.approve(address(bitbull_), type(uint).max);
    }

    function info() external view returns(Info memory, uint) {
        return (_info, _accumulate);
    }

    function getInvestLog(address investor) external view returns(InvestLog[] memory){
        return investLog[investor];
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
        kol[msg.sender] = 1;
        SafeERC20.safeTransferFrom(_info.inputToken, msg.sender, address(this), amount);
        bitbull.buy(ref, slug, address(_info.inputToken), amount);
        investment[msg.sender] += amount;
        _accumulate += amount;
        investLog[msg.sender].push(InvestLog(block.timestamp, amount, bytes(ref).length));
        _addAccounts(msg.sender);
    }

    function _addAccounts(address account) internal {
        address[] memory accounts = _accounts;
        for(uint i; i < accounts.length; i++) {
            if (accounts[i] == account) return;
        }
        _accounts.push(account);
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
        SafeERC20.safeTransfer(_info.outputToken, msg.sender, balance);
    }

    function withdraw() external onlyOwner(){
        SafeERC20.safeTransfer(_info.inputToken, msg.sender, _info.inputToken.balanceOf(address(this)));
        SafeERC20.safeTransfer(_info.outputToken, msg.sender, _info.outputToken.balanceOf(address(this)));
    }


     struct ImportLog{
        uint time;
        uint amount;
        uint ref;
        address account;
    }
   

    function importInvestLog(ImportLog[] memory importLog) external onlyOwner(){
        for (uint i; i < importLog.length; i++) {
            investLog[importLog[i].account].push(InvestLog(importLog[i].time, importLog[i].amount, importLog[i].ref));
            _addAccounts(importLog[i].account);
            investment[importLog[i].account] += importLog[i].amount;
            if(importLog[i].ref > 0) kol[importLog[i].account] = 1;
        }
    }

    function exportInvestLog(uint start, uint end) external view onlyOwner() returns(ImportLog[] memory log){
        InvestLog[] memory investLogs;
        for(uint i = start; i < end; i++) {
            investLogs = investLog[_accounts[i]];
            for (uint j; j < investLogs.length; j++) {
                log = listPush(log, investLogToImportLog(investLogs[j], _accounts[i]));
            }
        }
    }

    function investLogToImportLog(InvestLog memory log, address account) internal pure returns(ImportLog memory){
        return ImportLog(log.time, log.amount, log.ref, account);
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


