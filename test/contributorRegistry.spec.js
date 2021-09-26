const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ContributorRegistry", function () {
  before(async function () {
    [owner] = await ethers.getSigners();
  });
  it("Should return the correct owner", async function () {
    const ContributorRegistry = await ethers.getContractFactory(
      "ContributorRegistry"
    );
    const contributorRegistry = await ContributorRegistry.deploy();
    await contributorRegistry.deployed();

    expect(await contributorRegistry.owner()).to.equal(owner.address);
  });
});
