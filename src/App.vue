<template>
  <v-app>
    <v-app-bar :clipped-left="clipped" app fixed>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />

      <v-container class="d-flex align-center">
        <router-link to="/">
          <v-avatar tile size="100">
            <img alt="App Logo" src="./assets/logo.png" />
          </v-avatar>
        </router-link>
        <v-spacer />
        <v-slide-x-reverse-transition appear>
          <div class="d-flex">
            <div class="d-flex align-center ms-8">
              <!-- <connect-button :large="pcOnly" /> -->
            </div>
          </div>
        </v-slide-x-reverse-transition>
      </v-container>
    </v-app-bar>

    <v-main>
      <v-navigation-drawer
        v-model="drawer"
        :clipped="clipped"
        app
        class="navigationdrawer"
        stateless
      >
      </v-navigation-drawer>
      <div>
        <router-view />
      </div>
    </v-main>
  </v-app>
</template>
