// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract SwapV2{

    IUniswapV2Pair private uniswapV2Pair;
    address private token;

    constructor(address uniswapV2Pair_, address token_) {
        uniswapV2Pair = IUniswapV2Pair(uniswapV2Pair_);
        token = token_;
    }

    function _swapV2Rate(uint baseRate_) internal view virtual returns(uint) {
        bool isToken0 = token == uniswapV2Pair.token0();
        (uint reserve0, uint reserve1,) = uniswapV2Pair.getReserves();
        return (isToken0 ? reserve0 : reserve1) * baseRate_ * 2 / uniswapV2Pair.totalSupply();
    }

    function _unitPrice(uint baseRate_) internal view returns(uint) {
         bool isToken0 = token == uniswapV2Pair.token0();
         (uint reserve0, uint reserve1,) = uniswapV2Pair.getReserves();
         return (isToken0 ? reserve1 * baseRate_ / reserve0 : reserve0 * baseRate_ / reserve1);
    }
}