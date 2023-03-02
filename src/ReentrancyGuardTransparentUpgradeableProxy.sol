// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./StaticStorageSlotReentrancyGuard.sol";

/**
 * @title Reentrancy Guarded TransparentUpgradeableProxy
 * @author Ariel Tempelhof @ SphereX
 * @dev This contract implements the same interface as OZ TransparentUpgradeableProxy
 *      It adds a reentrancy check before calling the implementation
 */
contract ReentrancyGuardTransparentUpgradeableProxy is TransparentUpgradeableProxy, StaticStorageSlotReentrancyGuard {
    constructor(address _logic, address admin_, bytes memory _data)
        payable
        TransparentUpgradeableProxy(_logic, admin_, _data)
    {}

    function _internalDelegate(address _toimplementation) private nonReentrant returns (bytes memory) {
        bytes memory ret_data = Address.functionDelegateCall(_toimplementation, msg.data);
        return ret_data;
    }

    /**
     * @dev We can't call `TransparentUpgradeableProxy._delegate` because it uses an inline `RETURN`
     *      Since we have checks after the implementation call we need to save the return data,
     *      perform the checks, and only then return the data
     */
    function _delegate(address _toimplementation) internal override {
        bytes memory ret_data = _internalDelegate(_toimplementation);
        uint256 ret_size = ret_data.length;

        // slither-disable-next-line assembly
        assembly {
            return(add(ret_data, 0x20), ret_size)
        }
    }
}
