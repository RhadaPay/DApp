import { createApp } from "vue";
import App from "./App.vue";
import { vuetify } from "./plugins/vuetify";
import router from "./router";
import { store, key } from "./store/index";

document.title = "Rhada Dapp"

createApp(App).use(store, key).use(router).use(vuetify).mount("#app");
