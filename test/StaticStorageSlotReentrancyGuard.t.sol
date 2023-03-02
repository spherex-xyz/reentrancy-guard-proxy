// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StaticStorageSlotReentrancyGuard.sol";

contract NonReentrantContract is StaticStorageSlotReentrancyGuard {
    uint256 private testStorage;

    function externalFunction() external nonReentrant {
        testStorage++;
    }

    function externalCallsInternalFunction() external nonReentrant {
        internalFunction();
    }

    function internalFunction() internal nonReentrant {
        testStorage++;
    }

    function staticExternalFunction() external view nonReentrantStatic returns (uint256) {
        return testStorage;
    }

    function externalCallsStaticInternalFunction() external nonReentrant returns (uint256) {
        testStorage++;
        return staticInternalFunction();
    }

    function staticExternalCallsInternalFunction() external view nonReentrantStatic returns (uint256) {
        return staticInternalFunction();
    }

    function staticInternalFunction() internal view nonReentrantStatic returns (uint256) {
        return testStorage;
    }
}

contract StaticStorageSlotReentrancyGuardTest is Test {
    NonReentrantContract public testContract;

    function setUp() public {
        testContract = new NonReentrantContract();
    }

    function testExternal() public {
        testContract.externalFunction();
    }

    function testExternalCallsInternal() public {
        vm.expectRevert("ReentrancyGuard: reentrant call");
        testContract.externalCallsInternalFunction();
    }

    function testStaticExternal() public view {
        testContract.staticExternalFunction();
    }

    function testExternalCallsStaticInternal() public {
        vm.expectRevert("ReentrancyGuard: reentrant static call");
        testContract.externalCallsStaticInternalFunction();
    }

    function testStaticExternalCallsInternal() public view {
        testContract.staticExternalCallsInternalFunction();
    }
}
