import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';
import type { Contract } from 'ethers';
import type { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

interface TestContext {
  duckies: Contract
  owner: SignerWithAddress
  user: SignerWithAddress
  referer: SignerWithAddress
  others: SignerWithAddress[]
}

describe("Duckies", function () {
  beforeEach(async function () {
    const Duckies = await ethers.getContractFactory("Duckies");
    const duckies = await upgrades.deployProxy(Duckies);
    await duckies.deployed();
    this.duckies = duckies

    const [owner, user, referer, ...others] = await ethers.getSigners()
    this.owner = owner
    this.user = user
    this.referer = referer
    this.others = others
  })

  it("Should return the symbol", async function () {
    const { duckies }: TestContext = this as any
    expect(await duckies.symbol()).to.equal("DUCKZ");
  });

  it("Should setPayout correctly", async function () {
    const { duckies }: TestContext = this as any
    const payout = ethers.BigNumber.from(500)
    await duckies.setPayout(payout)
    expect(await duckies.payout()).to.equal(payout);
  });

  it("Should be rewarded correctly", async function () {
    const { duckies, user, referer, others: [alice, bob] }: TestContext = this as any
    const amount = ethers.utils.parseEther('100')
    const payoutPercent = ethers.BigNumber.from(5)

    await duckies.reward(alice.address, bob.address, amount)
    expect(await duckies.balanceOf(alice.address)).to.equal(amount)
    expect(await duckies.balanceOf(bob.address)).to.equal(amount.mul(payoutPercent))

    await duckies.reward(referer.address, alice.address, amount)
    expect(await duckies.balanceOf(referer.address)).to.equal(amount)
    expect(await duckies.balanceOf(alice.address)).to.equal(amount.mul(payoutPercent).add(amount))
    expect(await duckies.balanceOf(bob.address)).to.equal(amount.mul(payoutPercent).add(amount))

    await duckies.reward(user.address, referer.address, amount)
    expect(await duckies.balanceOf(user.address)).to.equal(amount)
    expect(await duckies.balanceOf(referer.address)).to.equal(amount.mul(payoutPercent).add(amount))
    expect(await duckies.balanceOf(alice.address)).to.equal(amount.mul(payoutPercent).add(amount).add(amount))
    expect(await duckies.balanceOf(bob.address)).to.equal(amount.mul(payoutPercent).add(amount).add(amount.div(payoutPercent)))
  });
});
