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
      <v-navigation-drawer v-model="drawer">
        <v-list v-if="errorType == null">
          <v-list-item
            v-for="(item, i) in items"
            :key="i"
            :to="item.to"
            router
            exact
            style="z-index: 1000"
          >
            <v-list-item-action>
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-item-action>
            <v-list-item-content>
              <v-list-item-title v-text="item.title" />
            </v-list-item-content>
          </v-list-item>
        </v-list>
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
const items = ref([
  { icon: "mdi-plus-box", title: "Contributor Registration", to: "/register" },
]);
</script>
