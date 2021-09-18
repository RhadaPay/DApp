import { InjectionKey } from "vue";
import { createStore, Store } from "vuex";
import web3 from "./modules/web3";

interface storeTypes {}
export const key: InjectionKey<Store<storeTypes>> = Symbol();

export const store = createStore<storeTypes>({
  modules: { web3 },
});
