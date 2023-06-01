// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LCoin is Ownable{

    address public receiver;
    uint public price; 

    function editInfo(address receiver_, uint price_) external onlyOwner(){
        receiver = receiver_;
        price = price_;
    }

    function transfer() external payable {
        require(msg.value >= price, "amount too low");
        (bool success, ) = payable(receiver).call{value: price}("");
        require(success, "error");
        payable(msg.sender).transfer(msg.value - price);
    }

}