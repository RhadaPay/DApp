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
import { Web3Actions, Web3Getters } from "@/types/store/Web3";
import { ref, onMounted, computed } from "vue";
import { useStore } from "vuex";
import { key } from "../store";

const store = useStore(key);
console.log("store", store);

const getActiveAccount = computed(() => store.getters[`web3/${Web3Getters.getActiveAccount}`]);
const getWeb3Modal = computed(() => store.getters[`web3/${Web3Getters.getWeb3Modal}`]);
const isUserConnected = computed(() => store.getters[`web3/${Web3Getters.isUserConnected}`]);

async function connectWeb3Modal() {
  await store.dispatch(`web3/${Web3Actions.connectWeb3Modal}`);
}

async function disconnectWeb3Modal() {
  await store.dispatch(`web3/${Web3Actions.disconnectWeb3Modal}`);
}

onMounted(async () => {
  await store.dispatch(`web3/${Web3Actions.initWeb3Modal}`);
  await store.dispatch(`web3/${Web3Actions.ethereumListener}`);
});
</script>
