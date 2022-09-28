// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./interfaces/IToucan.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
 * @author Cujo
 * @title ToucanFeeBurner takes any selective retirement fees and allows them to be burned by anyone.
 */

contract ToucanFeeBurner {
    using SafeERC20 for IERC20;

    event FeesBurned(address indexed poolToken, uint256 amount);

    function burnFees(address poolToken) external {
        uint256 currentAmount = IERC20(poolToken).balanceOf(address(this));
        require(currentAmount > 0, "No fees to burn");

        // Redeem pool tokens
        (address[] memory projectTokens, uint256[] memory amounts) = IToucanPool(poolToken).redeemAuto2(currentAmount);

        // Retire TCO2
        for (uint256 i = 0; i < projectTokens.length; i++) {
            if (amounts[i] == 0) continue;

            IToucanCarbonOffsets(projectTokens[i]).retire(amounts[i]);

            emit FeesBurned(poolToken, currentAmount);
        }
    }
}
