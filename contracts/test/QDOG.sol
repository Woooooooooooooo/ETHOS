// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract QDOG is ERC20Burnable {

    using Address for address;

    constructor(address to, string memory name_, string memory symbol_, uint amount) ERC20(name_, symbol_) {
        _mint(to, 10 ** decimals() * amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (!from.isContract() && !to.isContract()) {
            uint burnAmount = amount / 20;
            amount -= burnAmount;
            _burn(from, burnAmount);
        }
        super._transfer(from, to, amount);
    }
}
