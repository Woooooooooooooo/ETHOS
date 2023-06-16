// // SPDX-License-Identifier: GPL-3.0-or-later
// pragma solidity >=0.8.12 <0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


// contract EthosDao is Ownable{

//     using EnumerableSet for EnumerableSet.AddressSet;

//     struct Info {
//         IERC20 inputToken;
//         uint min;
//     }

//     Info public info;
//     EnumerableSet.AddressSet private _setAddr;
//     mapping(address => uint) private _balance;
//     mapping(address => uint) private _firstStakeTime;
//     mapping(bytes32 => uint) private _result;
    

//     function stake(uint amount) external {
//         require(amount >= info.min, 'too small');
//         _balance[msg.sender] += amount;
//         SafeERC20.safeTransferFrom(info.inputToken, msg.sender, address(this), amount);
//         _setAddr.add(msg.sender);
//         if (_firstStakeTime[msg.sender] == 0) _firstStakeTime[msg.sender] = block.timestamp;
//     }

//     function withdraw() external {
//         require(_balance[msg.sender] > 0, 'no balance');
//         SafeERC20.safeTransferFrom(info.inputToken, address(this), msg.sender, _balance[msg.sender]);
//         _balance[msg.sender] = 0;
//         _firstStakeTime[msg.sender] = 0;
//     }

//     function vote(String title) external {
//         _result[bytes(title)] = ;
//     }

// }