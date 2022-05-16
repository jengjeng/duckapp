// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @custom:security-contact security@ducks.house
contract Duckies is Initializable, ERC20CappedUpgradeable, PausableUpgradeable, OwnableUpgradeable {

    // Maximum Supply
    uint256 private constant _MAX_SUPPLY = 888000000000000;

    // Affiliate Tree
    mapping(address => address) private _referrers;
    // Affiliate Payouts
    uint32 private _payout;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("Yellow Duckies", "DUCKZ");
        __ERC20Capped_init(_MAX_SUPPLY * 10 ** decimals());
        __Pausable_init();
        __Ownable_init();

        _payout = 500;
        _mint(msg.sender, 44400000000000 * 10 ** decimals());
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     */
    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public onlyOwner {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setPayout(uint32 ratio) public onlyOwner {
        _payout = ratio;
    }

    function payout() public view returns (uint32) {
        return _payout / 100;
    }

    /**
     * @dev Mint referral rewards.
     *
     */
    function reward(address to, address ref, uint256 amount) public onlyOwner {

        require(to != address(0), "ERC20: reward to the zero address");
        require(ref != address(0), "ERC20: reward from the zero address");
        require(amount > uint256(0), "ERC20: amount must be higher than zero");

        _referrers[to] = ref;
        _mint(to, amount);
        _mint(ref, amount * payout());
        if (_referrers[ref] != address(0x0)) {
            _mint(_referrers[ref], amount);
            if (_referrers[_referrers[ref]] != address(0x0)) {
                _mint(_referrers[_referrers[ref]], amount / payout());
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
