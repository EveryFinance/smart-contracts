// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../common/AssetBook.sol";

/**
 * @author Every.finance.
 * @notice Implementation of the contract AssetBookGamma.
 */

contract AssetBookGamma is AssetBook {
    constructor(address admin_, address manager_) AssetBook(admin_, manager_) {}
}
