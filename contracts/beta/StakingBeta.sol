// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../staking/StakingToken.sol";

/**
 * @author Every.finance.
 * @notice Implementation of the contract StakingBeta.
 */

contract StakingBeta is StakingToken {
    constructor(
        address _token0,
        address _token1,
        address _admin,
        address _treasury
    ) StakingToken(_token0, _token1, _admin, _treasury) {}
}
