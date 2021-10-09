import { Web3Getters } from "@/types/store/Web3"
import { JsonRpcBatchProvider, Web3Provider } from "@ethersproject/providers"
import { ethers } from "ethers"
import { RoundManager } from "typechain"
import { ActionTree, GetterTree, Module, MutationTree } from "vuex"

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
    async vote ({ getters, dispatch }, payload: Vote): Promise<void> {
        const contract: RoundManager = getters.contract;
        const isElegibleToVote = await dispatch('checkEligibility', payload.addressFrom);
        if (contract && isElegibleToVote) {
            await contract.castVote(payload.roundId, payload.addressesFor)
        } else {
            console.warn('Could not find VoteManager contract, or the user is not confirmed')
        }
    },

    async checkEligibility ({ getters }, address: string): Promise<boolean> {
        const _address = address ?? getters[`web3/${Web3Getters.getActiveAccount}`];
        console.log(`Address ${address} is elegible`);
        return true
    },

    async checkAdmin ({ getters }, address: string): Promise<boolean> {
        const _address = address ?? getters[`web3/${Web3Getters.getActiveAccount}`];
        console.log(`Address ${address} is admin`);
        return true
    },

    async getContract({ commit }): Promise<void> {
        /**
         * @TODO get the live contract address so we can hook up to the ABI
         */
        const address: string = '';
        const abi: string = '';
        const provider = new ethers.providers.Web3Provider(JsonRpcBatchProvider);
        const contract = new ethers.Contract(address, abi, provider) as RoundManager
        commit('SET_CONTRACT', contract)
    },

    async closeRound (
        { getters },
        { roundId, address }: { roundId: number, address: string }
    ): Promise<void> {
        const CLOSED = 1;
        const contract: RoundManager = getters.contract;
        const isAdmin = await this.dispatch('vote/checkAdmin', address);
        if (contract && isAdmin) await contract.closeRound(roundId, CLOSED);
    },

    async getVotes (
        { getters },
        { roundId, _for }: { roundId: number , _for: string[] }
    ): Promise<Member[] | []> {
        const contract: RoundManager = getters.contract;
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

const mutations: MutationTree<any> = {
    SET_CONTRACT (contract: RoundManager) {
        state.contract = contract
    }
}

const getters: GetterTree<VoteState, any> = {
    contract (state): RoundManager | undefined {
        return state.contract 
    },

}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations,
} as Module<VoteState, any>