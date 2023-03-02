// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @title Static supported Storage Slot status Reentrancy Guard
 * @author Ariel Tempelhof @ SphereX
 * @dev abstract conntract to prevent reentrant calls
 *
 * This Reentrancy Guard difer from OZ one by few ways:
 * 1. `status` moved from normal contract storage to an arbitrary storage slot
 *      This is done to support Proxy guard not to clash with implementation storage
 * 2. Added `nonReentrantStatic` to allow guarding `view` and `pure` functions and
 *      prevent "read only reentrancy"
 * 3. `nonReentrant` checks if the current call is static. Helps in porxy cases where
 *      we don't know if we can store the flag or not
 */

abstract contract StaticStorageSlotReentrancyGuard {
    /**
     * @dev moved status to an arbitrary storage slot
     *      to not clash with implementation staorage
     */
    bytes32 private constant STATUS_STORAGE_SLOT = bytes32(uint256(keccak256("eip1967.reentrancy.status")) - 1);

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    /**
     * @dev event to be triggered when call is not static
     */
    event RentrancyStaticCallCheck();

    function _setReentrancyStatus(uint256 newStatus) private {
        StorageSlot.getUint256Slot(STATUS_STORAGE_SLOT).value = newStatus;
    }

    function _getReentrancyStatus() private view returns (uint256) {
        return StorageSlot.getUint256Slot(STATUS_STORAGE_SLOT).value;
    }

    /**
     * @dev This modifier adds a check whether we're not in a static call.
     *      Only then, the storage will be updated
     */
    modifier nonReentrant() {
        bool not_in_static = _nonReentrantBefore();
        _;
        if (not_in_static) {
            _nonReentrantAfter();
        }
    }

    /**
     * @dev only checks if the flag is on. prevents read only reentrancy
     */
    modifier nonReentrantStatic() {
        require(_getReentrancyStatus() != _ENTERED, "ReentrancyGuard: reentrant static call");
        _;
    }

    function staticCallCheck() external {
        emit RentrancyStaticCallCheck();
    }

    function _isStaticCall() private returns (bool) {
        try this.staticCallCheck() {
            return false;
        } catch {
            return true;
        }
    }

    function _nonReentrantBefore() private returns (bool) {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_getReentrancyStatus() != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail

        if (_isStaticCall()) {
            return false;
        } else {
            _setReentrancyStatus(_ENTERED);
            return true;
        }
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _setReentrancyStatus(_NOT_ENTERED);
    }
}
