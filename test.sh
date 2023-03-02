#!/bin/bash

pushd "$(dirname "$0")"

forge test -vv
npx hardhat test

popd