const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ContributorRegistry", function () {
  const requiredConfirmations = 2;
  let contributorRegistry;
  let contributorData = {};

  let owner, firstContributor;
  before(async function () {
    [owner, firstContributor] = await ethers.getSigners();
    contributorData[firstContributor.address] = {
      discordHandle: "firstDiscord",
      githubUsername: "firstGithub",
    };
  });
  it("Should return the correct owner", async function () {
    const ContributorRegistry = await ethers.getContractFactory(
      "ContributorRegistry"
    );
    contributorRegistry = await ContributorRegistry.deploy(
      requiredConfirmations
    );
    await contributorRegistry.deployed();

    expect(await contributorRegistry.owner()).to.equal(owner.address);
  });
  it("Should return the correct number of required confirmations", async function () {
    expect(await contributorRegistry.requiredConfirmations()).to.equal(
      requiredConfirmations
    );
  });
  it("Should be able to register", async function () {
    console.log(contributorData)
    const callData = contributorData[firstContributor.address];
    await contributorRegistry.connect(firstContributor).register(callData.discordHandle, callData.githubUsername)
  });
});
