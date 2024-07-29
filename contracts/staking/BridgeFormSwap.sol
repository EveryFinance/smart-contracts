// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BridgeFormSwap is AccessControlEnumerable, Pausable {
    using SafeERC20 for IERC20;

    address public token0;
    address public token1;
    address public treasury;

    event Swap(uint256 _amount, address indexed _account);

    constructor(
        address _token0,
        address _token1,
        address _admin,
        address _treasury
    ) {
        require(_token0 != address(0), "Every.Finance: zero address");
        require(_token1 != address(0), "Every.Finance: zero address");
        require(_admin != address(0), "Every.Finance: zero address");
        require(_treasury != address(0), "Every.Finance: zero address");
        token0 = _token0;
        token1 = _token1;
        treasury = _treasury;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setTreasury(
        address _treasury
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_treasury != address(0), "Every.Finance: zero address");
        treasury = _treasury;
    }

    function swap(uint256 _amount, address _to) public whenNotPaused {
        require(_to != address(0), "Every.Finance: zero address");
        require(_amount != 0, "Every.Finance: amount is zero");
        require(
            IERC20(token1).balanceOf(treasury) >= _amount,
            "Every.Finance: liquidity is not enough"
        );
        IERC20(token0).transferFrom(msg.sender, treasury, _amount);
        IERC20(token1).transferFrom(treasury, _to, _amount);
        emit Swap(_amount, _to);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
