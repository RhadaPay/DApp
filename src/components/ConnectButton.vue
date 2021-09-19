<template>
  <v-btn
    v-if="!isUserConnected"
    large
    rounded="pill"
    color="#f66502"
    @click="connectWeb3Modal"
  >
    <v-icon class="me-2" :size="20">mdi-link</v-icon>
    <span>Connect</span>
  </v-btn>
  <v-btn
    v-if="isUserConnected"
    large
    rounded="pill"
    color="#4e4e4f"
    @click="disconnectWeb3Modal"
  >
    <v-icon class="me-2" :size="20">mdi-link-off</v-icon>
    <span>Disconnect {{ getActiveAccount.substring(0, 7) }}...</span>
  </v-btn>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { useStore } from "vuex";
import { key } from "../store";

const store = useStore(key);
console.log("store", store);

const getActiveAccount = computed(() => store.getters["web3/getActiveAccount"]);
const getWeb3Modal = computed(() => store.getters["web3/getWeb3Modal"]);
const isUserConnected = computed(() => store.getters["web3/isUserConnected"]);

async function connectWeb3Modal() {
  await store.dispatch("web3/connectWeb3Modal");
}

async function disconnectWeb3Modal() {
  await store.dispatch("web3/disconnectWeb3Modal");
}

onMounted(async () => {
  await store.dispatch("web3/initWeb3Modal");
  await store.dispatch("web3/ethereumListener");
});
</script>
