# Reentrancy Guard Proxy

A Proxy contract incorporating a Reentrancy Guard

- Implements a standard OpenZeppelin [`TransparentUpgradableProxy`](https://docs.openzeppelin.com/contracts/4.x/api/proxy#TransparentUpgradeableProxy) interface
- Prevents reentrant extrenal calls through the proxy
- Prevents [Read only reentrancy](https://www.youtube.com/watch?v=8D5ZJyU-dX0)

## Motivation

While some protocols, such as Orion and Fei-Rari, employed ReentrancyGuard, they still suffered from reentrancy attacks.
This implementation now offers several benefits over the traditional approach:
- Developers no longer need to add the nonReentrant modifier to every function.
- Public functions can now be called internally while still being blocked externally.
- View and pure functions are now protected against "Read-Only Reentrancy" attacks.

## Installation

```bash
forge install Sphere-X-xyz/reentrancy-guard-proxy
```

(npm will be added in the future)

## Usage

```solidity
pragma solidity ^0.8.0;


import "reentrancy-guard-proxy/ReentrancyGuardTransparentUpgradeableProxy.sol";
```

The proxy should be deployed and used same as [Open Zeppelin proxies](https://docs.openzeppelin.com/contracts/4.x/api/proxy)

## Test

The `ReentrancyGuardTransparentUpgradeableProxy` and `StaticStorageSlotReentrancyGuard` pass all OpenZeppelin original tests for `TransparentUpgradeableProxy` and `ReentrancyGuard` respectively.

```bash
npx hardhat test
```

Other tests for specific unique cases were also introduced

```bash
forge test -vv
```

Or simply run:

```bash
./test.sh
```

## Caveats

- As with original proxies, it does not support `transfer` and `send` to the contract (due to gas limitation)
- The proxy contract, currently, does not have any exclusion mechanism, which means that callbacks to the same contract will be blocked, as they are essentially reentrant calls (e.g. ERC721 `onERC721Received` to the same contract)
- To check if the current context is a `STATICCALL`, we use a pattern in which we try to emit an event and check if it was successful. The side-effects are emitted event in case of a normal `CALL` and a partial revert in case of a `STATICCALL` (This is the only way currently, at least until [EIP-2770](https://eips.ethereum.org/EIPS/eip-2970) will be accepted)
