import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { RoundManager, RoundManager__factory } from "typechain";

describe("testing the Round Manager", () => {
    const LINKED_REGISTRY = "0x0000000000000000000000000000000000000000"

    let RMFactory: RoundManager__factory;
    let roundManager: RoundManager;

    before(async () => {
        RMFactory = await ethers.getContractFactory('RoundManager') as RoundManager__factory;
        roundManager = await RMFactory.deploy(LINKED_REGISTRY); 
    })
    
    it("Can check for registered contributors", async () => {
        
    });
    it("Can create a round with the status of 'Open'", async () => {});
    it("Can close the round if the user is an admin", async () => {});
    it("Can't close nor cancel the round if the user is not an admin", async () => {});
    it("Can cancel the round if the user is an admin", async () => {});
    it("Can't re-open a closed round", async () => {});
    it("Can't close a closed round", async () => {});
    it("Can't open and open round", async () => {});
    it("Cannot accept votes if the voter isn't registered", async () => {});
    it("Cannot accept votes if the candidate isn't registered", async () => {});
    it("Can accept an aribitrary number of votes from and to registered users", async () => {});
    it("Exposes the current votes tally", async () => {});
    it("Prevents voting for closed rounds", async () => {});
    it("Prevents double voting", async () => {});
})