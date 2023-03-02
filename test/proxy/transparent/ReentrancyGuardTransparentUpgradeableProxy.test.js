const shouldBehaveLikeProxy = require('../Proxy.behaviour');
const shouldBehaveLikeTransparentUpgradeableProxy = require('./ReentrancyGuardTransparentUpgradeableProxy.behaviour');

const ReentrancyGuardTransparentUpgradeableProxy = artifacts.require('ReentrancyGuardTransparentUpgradeableProxy');

contract('ReentrancyGuardTransparentUpgradeableProxy', function (accounts) {
  const [proxyAdminAddress, proxyAdminOwner] = accounts;

  const createProxy = async function (logic, admin, initData, opts) {
    return ReentrancyGuardTransparentUpgradeableProxy.new(logic, admin, initData, opts);
  };

  shouldBehaveLikeProxy(createProxy, proxyAdminAddress, proxyAdminOwner);
  shouldBehaveLikeTransparentUpgradeableProxy(createProxy, accounts);
});