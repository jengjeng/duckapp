import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';

describe("Duckies", function () {
  it("Should return the symbol", async function () {
    const Duckies = await ethers.getContractFactory("Duckies");
    const duckies = await upgrades.deployProxy(Duckies);
    await duckies.deployed();

    expect(await duckies.symbol()).to.equal("DUCKZ");
  });
});