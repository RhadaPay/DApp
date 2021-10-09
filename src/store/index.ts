import { InjectionKey } from "vue";
import { createStore, Store } from "vuex";
import vote from "./modules/vote";
import web3 from "./modules/web3";
import contributorRegistry from "./modules/contributorRegistry";

interface storeTypes {}
export const key: InjectionKey<Store<storeTypes>> = Symbol();

export const store = createStore<storeTypes>({
  modules: { web3, contributorRegistry, vote },
});
