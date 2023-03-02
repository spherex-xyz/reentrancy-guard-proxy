const { expectRevert } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const ReentrancyMockWithoutReentrancyGuard = artifacts.require('ReentrancyMockWithoutReentrancyGuard');
const ReentrancyAttack = artifacts.require('ReentrancyAttack');
const ReentrancyGuardTransparentUpgradeableProxy = artifacts.require('ReentrancyGuardTransparentUpgradeableProxy');

contract('ReentrancyGuardTransparentUpgradeableProxy', function (accounts) {
  const [proxyAdminAddress, proxyAdminOwner] = accounts;

  beforeEach(async function () {
    this.implementation = web3.utils.toChecksumAddress((await ReentrancyMockWithoutReentrancyGuard.new()).address);
    this.proxy = await ReentrancyGuardTransparentUpgradeableProxy.new(this.implementation,proxyAdminAddress,Buffer.from(''));
    this.proxyAddress = this.proxy.address;
    this.reentrancyMock = new ReentrancyMockWithoutReentrancyGuard(this.proxyAddress);
    expect(await this.reentrancyMock.counter()).to.be.bignumber.equal('0');
  });

  it('nonReentrant function can be called', async function () {
    expect(await this.reentrancyMock.counter()).to.be.bignumber.equal('0');
    await this.reentrancyMock.callback();
    expect(await this.reentrancyMock.counter()).to.be.bignumber.equal('1');
  });

  it('does not allow remote callback', async function () {
    const attacker = await ReentrancyAttack.new();
    await expectRevert(
      this.reentrancyMock.countAndCall(attacker.address), 'ReentrancyAttack: failed call');
  });

  // The following are more side-effects than intended behavior:
  // I put them here as documentation, and to monitor any changes
  // in the side-effects.
  it('does allow local recursion', async function () {
    await this.reentrancyMock.countLocalRecursive(10);
    expect(await this.reentrancyMock.counter()).to.be.bignumber.equal('10');
  });

  it('does not allow indirect local recursion', async function () {
    await expectRevert(
      this.reentrancyMock.countThisRecursive(10), 'ReentrancyMock: failed call',
    );
  });
});
