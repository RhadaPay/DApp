import Web3Modal from "web3modal";
import { ethers } from "ethers";
import {
  Web3Getters,
  Web3State,
  Web3Actions,
  Web3Mutations,
} from "@/types/store/Web3";
import { ActionTree, GetterTree, Module, MutationTree } from "vuex";

const state = {
  activeAccount: null,
  activeBalance: 0,
  chainId: null,
  chainName: null,
  isConnected: false,
  providerW3m: null, // this is "provider" from Web3Modal
  web3Modal: null,
} as Web3State;

const getters: GetterTree<Web3State, any> = {
  [Web3Getters.getActiveAccount](state) {
    return state.activeAccount;
  },
  [Web3Getters.getActiveBalanceWei](state) {
    return state.activeBalance;
  },
  [Web3Getters.getActiveBalanceEth](state) {
    return ethers.utils.formatEther(state.activeBalance);
  },
  [Web3Getters.getChainId](state) {
    return state.chainId;
    // return "80001"
  },
  [Web3Getters.getChainName](state) {
    return state.chainName;
  },
  [Web3Getters.getProviderEthers](state) {
    return new ethers.providers.Web3Provider(state.providerW3m);
  },
  [Web3Getters.getSigner](state, getters) {
    const provider = getters[Web3Getters.getProviderEthers]
    const activeAccount = getters[Web3Getters.getActiveAccount]
    return provider.getSigner(activeAccount);
  },
  [Web3Getters.getWeb3Modal](state) {
    return state.web3Modal;
  },
  [Web3Getters.isUserConnected](state) {
    return state.isConnected;
  },
};

const actions: ActionTree<Web3State, any> = {
  async [Web3Actions.initWeb3Modal]({ commit, dispatch }) {
    const providerOptions = {};

    const w3mObject = new Web3Modal({
      cacheProvider: true, // optional
      providerOptions, // required
    });

    commit(Web3Mutations.setWeb3ModalInstance, w3mObject);
  },

  async [Web3Actions.connectWeb3Modal]({ commit, dispatch }) {
    if (state.web3Modal) {
      let providerW3m = await state.web3Modal.connect();
      commit(Web3Mutations.setIsConnected, true);
      commit(Web3Mutations.setActiveAccount, window.ethereum.selectedAddress);
      commit(Web3Mutations.setChainData, window.ethereum.chainId);
      commit(Web3Mutations.setProviderW3m, providerW3m);
      dispatch(Web3Actions.fetchActiveBalance);
      await dispatch(Web3Actions.initializeContractData);
    }
  },

  async [Web3Actions.initializeContractData]({ dispatch }) {
    await dispatch("contributorRegistry/loadRegisteredContributors", null, {
      root: true,
    });
    await dispatch("contributorRegistry/registerListeners", null, {
      root: true,
    });
  },

  async [Web3Actions.disconnectWeb3Modal]({ commit }) {
    commit(Web3Mutations.disconnectWallet);
    commit(Web3Mutations.setIsConnected, false);
  },

  async [Web3Actions.ethereumListener]({ commit, dispatch }) {
    window.ethereum.on("accountsChanged", (accounts: string[]) => {
      if (state.isConnected) {
        commit(Web3Mutations.setActiveAccount, accounts[0]);
        dispatch(Web3Actions.fetchActiveBalance);
      }
    });

    window.ethereum.on("chainChanged", (chainId: number) => {
      commit(Web3Mutations.setChainData, chainId);
      dispatch(Web3Actions.fetchActiveBalance);
      dispatch(Web3Actions.initializeContractData);
    });
  },

  async [Web3Actions.fetchActiveBalance]({ commit, getters }) {
    if (state.providerW3m && state.activeAccount) {
      let providerEthers = getters["getProviderEthers"];
      let balance = await providerEthers.getBalance(state.activeAccount);
      commit(Web3Mutations.setActiveBalance, balance);
    }
  },
};

const mutations: MutationTree<Web3State> = {
  async [Web3Mutations.disconnectWallet](state) {
    state.activeAccount = null;
    state.activeBalance = 0;
    if (state.providerW3m.close && state.providerW3m !== null) {
      await state.providerW3m.close();
    }
    state.providerW3m = null;
    if (state.web3Modal) {
      state.web3Modal.clearCachedProvider();
    }
    window.location.href = "../"; // redirect to the Main page
  },

  [Web3Mutations.setActiveAccount](state, selectedAddress) {
    state.activeAccount = selectedAddress;
  },

  [Web3Mutations.setActiveBalance](state, balance) {
    state.activeBalance = balance;
  },

  [Web3Mutations.setChainData](state, chainId) {
    state.chainId = chainId;

    switch (chainId) {
      case "0x1":
        state.chainName = "Mainnet";
        break;
      case "0x2a":
        state.chainName = "Kovan";
        break;
      case "0x3":
        state.chainName = "Ropsten";
        break;
      case "0x4":
        state.chainName = "Rinkeby";
        break;
      case "0x5":
        state.chainName = "Goerli";
        break;
      case "0x539": // 1337 (often used on localhost)
      case "0x1691": // 5777 (default in Ganache)
      default:
        state.chainName = "Localhost";
        break;
    }
  },

  [Web3Mutations.setIsConnected](state, isConnected) {
    state.isConnected = isConnected;
    // add to persistent storage so that the user can be logged back in when revisiting website
    localStorage.setItem("isConnected", isConnected);
  },

  [Web3Mutations.setWeb3ModalInstance](state, w3mObject) {
    state.web3Modal = w3mObject;
  },

  [Web3Mutations.setProviderW3m](state, providerW3m) {
    state.providerW3m = providerW3m;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
} as Module<Web3State, any>;
