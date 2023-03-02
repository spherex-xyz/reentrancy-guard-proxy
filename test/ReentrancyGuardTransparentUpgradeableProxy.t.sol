// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ReentrancyGuardTransparentUpgradeableProxy.sol";
import "../src/StaticStorageSlotReentrancyGuard.sol";

contract DummyProxiedContract {
    bool private dummystorage;
    bool public received;

    function normalFunction() external {}

    function reentrantCall() external {
        DummyProxiedContract(payable(this)).reentrantCallInternal();
    }

    function reentrantCallInternal() external {}

    function staticCall() external pure returns (bool) {
        return true;
    }

    function callToStaticReentrant() external returns (bool) {
        dummystorage = true;
        return DummyProxiedContract(payable(this)).staticCall();
    }

    function staticToStaticReentrant() external view returns (bool) {
        return DummyProxiedContract(payable(this)).staticCall();
    }

    receive() external payable {
        received = true;
    }
}

contract DummyProxiedContract2 {
    function returnTrue() external pure returns (bool) {
        return true;
    }
}

contract ReentrancyGuardTransparentUpgradeableProxyTest is Test {
    ReentrancyGuardTransparentUpgradeableProxy public proxy;
    DummyProxiedContract public proxy_interface;

    event RentrancyStaticCallCheck();

    function setUp() public {
        DummyProxiedContract proxiedContract = new DummyProxiedContract();
        proxy = new ReentrancyGuardTransparentUpgradeableProxy(address(proxiedContract), address(0x10000), "");
        proxy_interface = DummyProxiedContract(payable(proxy));
    }

    function testNormalFunction() public {
        vm.expectEmit(false, false, false, false, address(proxy));
        emit RentrancyStaticCallCheck();

        proxy_interface.normalFunction();
    }

    function testTwoNormalCalls() public {
        vm.expectEmit(false, false, false, false, address(proxy));
        emit RentrancyStaticCallCheck();

        proxy_interface.normalFunction();

        vm.expectEmit(false, false, false, false, address(proxy));
        emit RentrancyStaticCallCheck();

        proxy_interface.normalFunction();
    }

    function testReentrantCall() public {
        vm.expectRevert("ReentrancyGuard: reentrant call");
        proxy_interface.reentrantCall();
    }

    function testStaticCall() public {
        assertTrue(proxy_interface.staticCall());
    }

    function testCallToStaticReentrant() public {
        vm.expectRevert("ReentrancyGuard: reentrant call");
        proxy_interface.callToStaticReentrant();
    }

    function testStaticToStaticReentrant() public {
        assertTrue(proxy_interface.staticCall());
    }

    function testCallWithValue() public {
        (bool success,) = payable(proxy_interface).call{value: 1 ether}("");
        assertTrue(success);
        assertTrue(proxy_interface.received());
    }

    function testTransfer() public {
        vm.expectRevert(bytes(""));
        payable(proxy_interface).transfer(1 ether);
    }

    function testUpgrade() public {
        DummyProxiedContract2 dummy2 = new DummyProxiedContract2();
        vm.prank(address(0x10000));
        proxy.upgradeTo(address(dummy2));
        DummyProxiedContract2 proxy_interface2 = DummyProxiedContract2(address(proxy));

        assertTrue(proxy_interface2.returnTrue());
    }

    function testGasConsumtion1() public {
        vm.pauseGasMetering();
        vm.resumeGasMetering();
        proxy_interface.normalFunction();
    }

    function testGasConsumtion2() public {
        vm.pauseGasMetering();
        vm.prank(address(0x10000));
        TransparentUpgradeableProxy transparent_proxy =
            new TransparentUpgradeableProxy(proxy.implementation(), address(0x10000), "");

        DummyProxiedContract transparent_proxy_interface = DummyProxiedContract(payable(transparent_proxy));
        vm.resumeGasMetering();
        transparent_proxy_interface.normalFunction();
    }
}
