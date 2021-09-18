<template>
  <v-app>
    <v-app-bar app fixed>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />

      <v-container class="d-flex align-center">
        <router-link to="/">
          <img height="50" alt="App Logo" src="./assets/logo.png" />
        </router-link>
        <v-spacer />
        <v-slide-x-reverse-transition appear>
          <div class="d-flex">
            <div class="d-flex align-center ms-8">
              <connect-button />
            </div>
          </div>
        </v-slide-x-reverse-transition>
      </v-container>
    </v-app-bar>

    <v-main>
      <v-navigation-drawer
        v-model="drawer"
      >
      </v-navigation-drawer>
      <div>
        <router-view />
      </div>
    </v-main>
  </v-app>
</template>
<script setup lang="ts">
import ConnectButton from "./components/ConnectButton.vue";
import { ref } from "vue";
const drawer = ref(true);
</script>
