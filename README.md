# Reentrancy Guard Proxy

A Proxy contract incorporating a Reentrancy Guard

- Implementing standard OpenZeppelin [`TransparentUpgradableProxy`](https://docs.openzeppelin.com/contracts/4.x/api/proxy#TransparentUpgradeableProxy) interface
- Blocks reentrant extrenal calls through the proxy
- Blocks [Read only reentrancy](https://www.youtube.com/watch?v=8D5ZJyU-dX0)

## Motivation

Too many protocols were hacked by a reentrancy attack, although `ReentrancyGuard` was utilized in some sort (e.g. Orion, Fei-Rari).
This implementation solves a few problems in normal `ReentrancyGuard`:

- Developers don't need to add the `nonReentrant` modifier to every function
- `public` functions can now be called internally while still being blocked externally
- `view` and `pure` functions are also being protected from "Read-Only Reentrancy"

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
