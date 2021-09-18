<template>
  <v-btn v-if="!isConnected" large rounded="pill" color="#f66502" @click="connect">
    <v-icon class="me-2" :size="20">mdi-link</v-icon>
    <span>Connect</span>
  </v-btn>
  <v-btn v-else large rounded="pill" color="#4e4e4f" @click="disconnect">
    <v-icon class="me-2" :size="20">mdi-link-off</v-icon>
    <span>Disconnect</span>
  </v-btn>
</template>

<script setup lang="ts">
import { ref } from "vue";
const isConnected = ref(false)

function connect(){
    isConnected.value = true;
}
function disconnect(){
    isConnected.value = false;
}

</script>
