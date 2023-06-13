// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LCoin is Ownable{

    using SafeERC20 for ERC20;

    mapping(address => uint) private _bill;
    ERC20 public token;
    address public proxyAddr;

    struct Bill{
        address account;
        uint amount;
    }

    function importBill(Bill[] memory bill) external onlyOwner {
        for (uint i; i < bill.length; i++) {
            _bill[bill[i].account] = bill[i].amount;
        }
    }

    function setInfo(ERC20 token_, address proxyAddr_) external onlyOwner {
        token = token_;
        proxyAddr = proxyAddr_;
    }

    function withdraw() external payable {
        uint amount = _bill[msg.sender];
        require(amount > 0, "Unable to claim");
        token.safeTransferFrom(proxyAddr, msg.sender, amount);
    }

}