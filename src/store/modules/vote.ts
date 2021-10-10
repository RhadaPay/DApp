import { Web3Getters } from "@/types/store/Web3"
import { ethers } from "ethers"
import { RoundManager } from "typechain"
import { ActionTree, GetterTree, Module, MutationTree } from "vuex"
import { RoundManager__factory } from "../../../typechain/factories/RoundManager__factory";

const ROUND_MANAGER_CONTRACT = "0xBD0eDbD7262B129086a4eb3E69105FB7CAc30093"
declare global {
  interface Window {
    ethereum: {
      request(...args: any[]): Promise<ethers.providers.Provider>;
      selectedAddress: string;
    };
  }
}


interface Member {
    address: string;
    votesThisRound: number;
    github?: string;
    discord?: string;
}

interface VoteState {
    confirmedMembers: Member[] | [];
    currentRound: number;
    DAO: string;
    contract?: RoundManager;
}

const state: VoteState = {
    confirmedMembers: [],
    currentRound: 0,
    DAO: '',
}

interface Vote {
    roundId: number;
    addressesFor: string[];
    addressFrom: string; 
}

const actions: ActionTree<VoteState, any> = {
    async vote ({  dispatch }, payload: Vote): Promise<void> {
        const contract: RoundManager = await dispatch('getContract');
        const isElegibleToVote = await dispatch('checkEligibility', payload.addressFrom);
        if (contract && isElegibleToVote) {
            console.debug({ contract })
            await contract.castVote(payload.roundId, payload.addressesFor)
        } else {
            console.warn('Could not find VoteManager contract, or the user is not confirmed')
        }
    },

    async checkEligibility ({ getters }, address: string): Promise<boolean> {
        console.log(`Address ${address} is elegible`);
        return true
    },

    async checkAdmin ({ getters }, address: string): Promise<boolean> {
        console.log(`Address ${address} is admin`);
        return true
    },

    async getContract({ }): Promise<RoundManager> {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        
        const _contract = RoundManager__factory.connect(
            ROUND_MANAGER_CONTRACT,
            signer
        );        
        return _contract
    },

    async closeRound (
        { dispatch },
        { roundId, address }: { roundId: number, address: string }
    ): Promise<void> {
        const CLOSED = 1;
        const contract: RoundManager = await dispatch('getContract');
        const isAdmin = await dispatch('checkAdmin', address);
        if (contract && isAdmin) await contract.closeRound(roundId, CLOSED);
    },

    async getVotes (
        { dispatch },
        { roundId, _for }: { roundId: number , _for: string[] }
    ): Promise<Member[] | []> {
        const contract: RoundManager = await dispatch('getContract');
        const memberIds: string[] = _for ?? [''];
        if (contract) {
            console.log('Found contract');
            const votes: Member[] = await Promise.all(
                memberIds.map(async (id): Promise<Member> => {
                    const vote = await contract.getRoundVotesPerUser(id, roundId) ?? 0;
                    return { address: id, votesThisRound: vote.toNumber() }
                })
            )
            return votes
        }
        console.log('Did not find contract');
        return [ await Promise.resolve({ address: memberIds[0], votesThisRound: 1 })]        
    }
}


export default {
    namespaced: true,
    state,
    actions,
} as Module<VoteState, any>