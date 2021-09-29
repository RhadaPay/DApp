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
    const numRegisteredContributorsBefore = await contributorRegistry.numRegisteredContributors();

    const methodArguments = contributorData[firstContributor.address];
    await contributorRegistry
      .connect(firstContributor)
      .register(methodArguments.discordHandle, methodArguments.githubUsername);

    const numRegisteredContributorsAfter = await contributorRegistry.numRegisteredContributors();
    expect(numRegisteredContributorsAfter - numRegisteredContributorsBefore).to.equal(1)
  });

  it("Should return contributor Data", async function () {
    const result = await contributorRegistry.contributors(
      firstContributor.address
    );
    expect(result.discordHandle).to.equal(
      contributorData[firstContributor.address].discordHandle
    );
    expect(result.githubUsername).to.equal(
      contributorData[firstContributor.address].githubUsername
    );
  });

  it("Should return list of registered addresses", async function () {
    const addressList = await contributorRegistry.registeredContributorAddresses();
    expect(addressList).to.contain(
      firstContributor.address
    );
  });


  it("Owner should be able to confirm contributor unilaterally", async function () {
    await contributorRegistry
      .connect(owner)
      .confirm(firstContributor.address);
  });

  it("Owner should be able to unregister contributor unilaterally", async function () {
    const numRegisteredContributorsBefore = await contributorRegistry.numRegisteredContributors();

    await contributorRegistry
      .connect(owner)
      .unregister(firstContributor.address);

    const numRegisteredContributorsAfter = await contributorRegistry.numRegisteredContributors();
    expect(numRegisteredContributorsAfter - numRegisteredContributorsBefore).to.equal(-1)
  });
});
