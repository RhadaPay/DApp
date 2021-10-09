<template>
  <v-card class="mx-auto my-12" max-width="500">
    <v-card-title>Register New Contributor</v-card-title>
    <form>
      <v-card-text>
        <v-container>
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="discordHandle"
                label="Discord Handle"
                required
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="githubUsername"
                label="Github Username"
                required
              ></v-text-field>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>

        <v-btn
          color="blue darken-1"
          type="button"
          @click.prevent="register"
          :loading="loading"
          :disabled="loading"
        >
          Register
          <template #loader>
            <span>Loading...</span>
          </template>
        </v-btn>
      </v-card-actions>
    </form>
  </v-card>
</template>

<script>
import { mapActions } from "vuex";
export default {
  data: () => ({
      loading: false,
      discordHandle: "Not Found",
      githubUsername: "Not Found",
  }),
  methods: {
    ...mapActions("contributorRegistry", ["registerContributor"]),
    async register() {
      try {
        this.loading = true;
        await this.registerContributor({
          discordHandle: this.discordHandle,
          githubUsername: this.githubUsername,
        });
      } catch (e) {
        console.error("Contributor Registration failed with exception: ", e);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

