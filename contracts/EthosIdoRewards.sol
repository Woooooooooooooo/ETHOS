// // SPDX-License-Identifier: GPL-3.0-or-later
// pragma solidity >=0.8.12 <0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./interface/IBitbull.sol";

// contract EthosIdoRewards is Ownable{

//     struct InvestLog{
//         address account;
//         uint time;
//         uint amount;
//         string ref;
//     }

//     struct thawInfo{
//         uint256 date;       //释放时间
//         uint256 proportion; //释放比例万分之几
//     }

//     struct Info{
//         uint targetAmount;
//         uint totalAmount;
//         uint min;
//         uint max;
//         uint price;
//         uint decimalPlace;
//         uint startTime;
//         uint endTime;
//         IERC20 inputToken;
//         IERC20 outputToken;
//     }
    
//     uint constant private kolProportion = 300;
//     uint constant private BASE_PROPORTION = 10000;
//     Info private _info;
//     mapping(address => uint) investment;
//     mapping(address => uint) payed;
//     mapping(address => uint) kol;
//     mapping(address => InvestLog[]) public investLogs;
//     thawInfo[] private _thawInfoList;

//     constructor(Info memory info_) {
//         _info = info_;
//         _thawInfoList.push(thawInfo(1686564000, 800));
//         for (uint i; i < 23; i++ ) {
//             _thawInfoList.push(thawInfo(1686564000 + (30 days * (i + 1)) , 400));
//         }
//     }

//     function importInvestLog(InvestLog[] memory investLog_) external onlyOwner(){
//         for(uint i; i < investLog_.length; i++){
//             investLogs[investLog_[i].account].push(investLog_[i]);
//         }
//     }

//     function updateInvestLog(uint i, InvestLog memory log) external onlyOwner() {
//         investLogs[log.account][i] = log;
//     }
    
//     function thawInfoList() external view returns(thawInfo[] memory){
//         return _thawInfoList;
//     }

//      function _getThawProportion(uint256 date) internal view returns(uint256 proportion){
//         thawInfo[] memory thawInfoList_ = _thawInfoList;
//         for(uint256 i = 0; i < _thawInfoList.length; i++) {
//             if (date >= thawInfoList_[i].date) proportion += thawInfoList_[i].proportion;
//         }
//     }

//     function expected(address account, uint time) public view returns(uint total, uint balance, uint additional){
//         uint proportion = _getThawProportion(time);
//         // investment[account] / (_info.price / _info.decimalPlace) * (proportion / BASE_PROPORTION);
//         total = investment[account] * _info.decimalPlace * proportion / _info.price / BASE_PROPORTION;
//         if (kol[account] == 1) 
//             additional = total * kolProportion / BASE_PROPORTION;
//             total += additional;
//         balance = total - payed[account];
//     }

//     function getRewards() public {
//         (, uint256 balance,)= expected(msg.sender, block.timestamp);
//         require(balance > 0, "No available balance");
//         payed[msg.sender] += balance;
//         SafeERC20.safeTransfer(_info.outputToken, msg.sender, balance);
//     }

//     function withdraw() external onlyOwner(){
//         SafeERC20.safeTransfer(_info.inputToken, msg.sender, _info.inputToken.balanceOf(address(this)));
//         SafeERC20.safeTransfer(_info.outputToken, msg.sender, _info.outputToken.balanceOf(address(this)));
//     }

// }


