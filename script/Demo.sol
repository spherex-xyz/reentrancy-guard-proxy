pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ReentrancyGuardTransparentUpgradeableProxy.sol";
import "../test/mocks/ReentrancyMockWithoutReentrancyGuard.sol";
import "../test/mocks/ReentrancyAttack.sol";

/**
 * @dev run this file with
 *      forge script script/Demo.sol -vvvv
 *      To see how the reentrant call reverts from the proxy
 */
contract MyScript is Script {
    function run() external {
        address proxyAdmin = address(0x10000);

        ReentrancyMockWithoutReentrancyGuard implementation = new ReentrancyMockWithoutReentrancyGuard();
        ReentrancyGuardTransparentUpgradeableProxy proxy =
            new ReentrancyGuardTransparentUpgradeableProxy(address(implementation), proxyAdmin, '');
        ReentrancyMockWithoutReentrancyGuard proxyInterface = ReentrancyMockWithoutReentrancyGuard(address(proxy));

        proxyInterface.countLocalRecursive(10);

        ReentrancyAttack attacker = new ReentrancyAttack();
        proxyInterface.countAndCall(attacker);
    }
}
