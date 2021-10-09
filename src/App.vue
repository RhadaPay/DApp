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
              <v-chip v-if="isAdmin" color="warning" class="mx-0 px-5">ADMIN</v-chip>
              <v-chip v-if="isConfirmed" color="secondary" class="mx-3 px-5">CONFIRMED USER</v-chip>
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
            <v-list-item-action class="mr-5">
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
<script lang="ts">
import ConnectButton from "./components/ConnectButton.vue";
import { defineComponent } from 'vue'
export default defineComponent({
  components: { ConnectButton },
  data: () => ({
    drawer: true,
    errorType: null,
    isAdmin: true,
    isConfirmed: true,
    items: [
      { icon: "mdi-home", title: "Home", to: "/" },
      { icon: "mdi-plus-box", title: "Contributor Registration", to: "/register" },
      { icon: "mdi-format-list-bulleted-square", title: "Contributor List", to: "/contributors" },
      { icon: "mdi-vote", title: "Vote", to: "/vote" },      
    ]
  }),
  async mounted() {
    // get the admin status of the user
  }
});
</script>
