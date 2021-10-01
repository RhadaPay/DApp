import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { RoundManager, RoundManager__factory } from "typechain";

describe("testing the Round Manager", () => {
    const LINKED_REGISTRY = "0x0000000000000000000000000000000000000000"

    let RMFactory: RoundManager__factory;
    let roundManager: RoundManager;
    let [owner, admin, member, nonMember] = [] as SignerWithAddress[];

    before(async () => {
        [owner, admin, member, nonMember] = await ethers.getSigners();
        RMFactory = await ethers.getContractFactory('RoundManager') as RoundManager__factory;
        roundManager = await RMFactory.deploy(LINKED_REGISTRY); 
        await roundManager.openRound(); // close
        await roundManager.openRound(); // cancel
        await roundManager.openRound(); // keep open
    });
    
    it("Can create a round with the status of 'Open'", async () => {
        const round = await roundManager.getRound(0);
        expect(round.status).to.be('Open');
    });

    it("Can't close nor cancel the round if the user is not an admin", async () => {
        const roundId = 0;
        await expect(roundManager.closeRound(roundId))
            .to.be.revertedWith("Only admins can close rounds");

        await expect(roundManager.cancelRound(roundId))
            .to.be.revertedWith("Only admins can cancel rounds");
    });

    it("Can close the round if the user is an admin", async () => {
        const roundId = 0;
        await roundManager.closeRound(roundId);
        const round = await roundManager.getRound(roundId);
        expect(round.status).to.be('Closed');        
    });

    it("Can cancel the round if the user is an admin", async () => {
        const roundId = 1;
        await roundManager.cancelRound(roundId);
        const round = await roundManager.getRound(roundId);
        expect(round.status).to.be('Cancelled');   
    });


    it("Can't close nor cancel or closed round", async () => {
        const roundId = 0;
        await expect(roundManager.closeRound(roundId))
            .to.be.revertedWith("Round already closed");
        await expect(roundManager.cancelRound(roundId))
            .to.be.revertedWith("Round already closed");
    });
    it("Can't close nor cancel a cancelled round", async () => {
        const roundId = 1;
        await expect(roundManager.closeRound(roundId))
            .to.be.revertedWith("Round already cancelled");
        await expect(roundManager.cancelRound(roundId))
            .to.be.revertedWith("Round already cancelled");

    });

    it("Cannot accept votes if the voter isn't registered", async () => {
        const roundId = 2;
        const _for = member.address;
        const numberOfVotes = 1;
        await expect(roundManager.castVote(
            roundId,
            _for,
            numberOfVotes
        ))
        .to.be.revertedWith("Voter is not registered");
    });

    it("Cannot accept votes if the candidate isn't registered", async () => {
        const roundId = 2;
        const _for = nonMember.address;
        const numberOfVotes = 1;
        await expect(roundManager.castVote(
            roundId,
            _for,
            numberOfVotes
        ))
        .to.be.revertedWith("Candidate is not registered");
    });

    it("Can accept an aribitrary number of votes from and to registered users", async () => {
        const roundId = 2;
        const _for = member.address;
        const numberOfVotes = Math.floor(Math.random() * 100);
        await roundManager.castVote(roundId, _for, numberOfVotes);
    });

    it("Exposes the current votes tally", async () => {
        expect(1).to.eq(0);
    });

    it("Prevents voting for closed rounds", async () => {
        const roundId = 0;
        const _for = member.address;
        const numberOfVotes = 1;
        await expect(roundManager.castVote(
            roundId,
            _for,
            numberOfVotes
        ))
        .to.be.revertedWith("Round is closed");
    });

    it("Prevents voting for cancelled rounds", async () => {
        const roundId = 1;
        const _for = member.address;
        const numberOfVotes = 1;
        await expect(roundManager.castVote(
            roundId,
            _for,
            numberOfVotes
        ))
        .to.be.revertedWith("Round is cancelled");
    });    

    it("Prevents double voting", async () => {
        const roundId = 2;
        const _for = member.address;
        const numberOfVotes = Math.floor(Math.random() * 100);
        await expect(roundManager.castVote(roundId, _for, numberOfVotes))
            .to.be.revertedWith("Member has already voted");
    });
})