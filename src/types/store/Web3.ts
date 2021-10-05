import { providers } from "ethers";
import Web3Modal from "web3modal";

export enum Web3Getters {
    getActiveAccount = 'getActiveAccount',
    getActiveBalanceWei = 'getActiveBalanceWei',
    getActiveBalanceEth = 'getActiveBalanceEth',
    getChainId = 'getChainId',
    getChainName = 'getChainName',
    getProviderEthers = 'getProviderEthers',
    getSigner = 'getSigner',
    getWeb3Modal = 'getWeb3Modal',
    isUserConnected = 'isUserConnected'
}

export enum Web3Actions {
    initWeb3Modal = 'initWeb3Modal',
    initializeContractData = 'initializeContractData',
    connectWeb3Modal = 'connectWeb3Modal',
    disconnectWeb3Modal = 'disconnectWeb3Modal',
    ethereumListener = 'ethereumListener',
    fetchActiveBalance = 'fetchActiveBalance',
}

export enum Web3Mutations {
    disconnectWallet = 'disconnectWallet',
    setActiveAccount = 'setActiveAccount',
    setActiveBalance = 'setActiveBalance',
    setChainData = 'setChainData',
    setIsConnected = 'setIsConnected',
    setProviderW3m = 'setProviderW3m',
    setWeb3ModalInstance = 'setWeb3ModalInstance',
}

export interface Web3State {
    activeAccount: null | string,
    activeBalance: number,
    chainId: null | string,
    chainName: null | string,
    providerEthers: null | providers.Provider, // this is "provider" for Ethers.js
    isConnected: boolean,
    providerW3m: null | any, // this is "provider" from Web3Modal
    web3Modal: null | Web3Modal
}
