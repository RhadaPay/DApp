import { ethers } from "ethers";
import addresses from "@/contracts/addresses.json";
import { abi } from "@/contracts/ContributorRegistry.json";
import { Web3Getters } from "@/types/store/Web3";

type ChainId = "31337";

const state = {
  registeredContributors: null,
  contract: null,
};

const getters = {
  getRegisteredContributors(state) {
    return state.registeredContributors;
  },
};

const actions = {
  connectContract({ rootGetters }) {
    const provider = rootGetters[`web3/${Web3Getters.getProviderEthers}`];
    const chainId =  rootGetters[`web3/${Web3Getters.getChainId}`];
    const chainIdDec = parseInt(chainId).toString() as ChainId;
    const address = addresses.ContributorRegistry[chainIdDec];
    console.debug({ Web3Getters, address, chainIdDec, provider,  chainId, rootGetters });
    if (address === undefined) {
      console.error(
        `Contributor Registry not deployed on chainId ${chainIdDec}`
      );
      return null;
    } else {
      return new ethers.Contract(address, abi, provider);
    }
  },

  async registerListeners({dispatch}){
    const contract = await dispatch("connectContract");

      // For now just reload all contributor data on any event
      contract.on("Registered", async () => {
          await dispatch("loadRegisteredContributors")
      });
      contract.on("UnRegistered", async () => {
          await dispatch("loadRegisteredContributors")
      });
      contract.on("ConfirmationVote", async () => {
          await dispatch("loadRegisteredContributors")
      });
      contract.on("ContributorConfirmed", async () => {
          await dispatch("loadRegisteredContributors")
      });
  },
  async loadRegisteredContributors({ dispatch, commit }) {
    const contract = await dispatch("connectContract");

    if (contract != null) {
      let registeredContributorAddresses =
        await contract.callStatic.registeredContributorAddresses();
      const registeredContributorData = await Promise.all(
        registeredContributorAddresses.map(
          async (contributorAddress: string) => {
            const [statusId, confirmationVotes, discordHandle, githubUsername] =
              await contract.callStatic.contributors(contributorAddress);
            return {
              address: contributorAddress,
              statusId,
              confirmationVotes,
              discordHandle,
              githubUsername,
            };
          }
        )
      );

      commit("setRegisteredContributors", registeredContributorData);
    }
  },

  async registerContributor(
    { dispatch, rootGetters },
    { discordHandle, githubUsername }
  ) {
    const contract = await dispatch("connectContract");

    if (contract != null) {
      const singer = rootGetters[`web3/${Web3Getters.getSigner}`];
      await contract.connect(singer).register(discordHandle, githubUsername);
    }
  },

  async confirmContributor({ dispatch, rootGetters }, { address }) {
    const contract = await dispatch("connectContract");

    if (contract != null) {
      const singer = rootGetters[`web3/${Web3Getters.getSigner}`];
      await contract.connect(singer).confirm(address);
    }
  },
};

const mutations = {
  setRegisteredContributors(state, registeredContributors) {
    return (state.registeredContributors = registeredContributors);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
