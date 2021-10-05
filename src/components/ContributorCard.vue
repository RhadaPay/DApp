<template>
  <v-card class="mx-auto my-12" max-width="500">
    <v-card-title>{{ address }}</v-card-title>
    <v-card-text>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>Discord Handle</v-list-item-title>
          <v-list-item-subtitle>{{ discordHandle }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>Github Username</v-list-item-title>
          <v-list-item-subtitle>{{ githubUsername }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>Status</v-list-item-title>
          <v-list-item-subtitle>{{ statusString }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>Confirmation Votes</v-list-item-title>
          <v-list-item-subtitle>{{ confirmationVotes }}</v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>

      <v-card-actions v-if="statusId != 2">
        <v-spacer></v-spacer>

        <v-btn
          color="blue darken-1"
          type="button"
          @click.prevent="confirm"
          :loading="loading"
          :disabled="loading"
        >
          Confirm Registration
          <template #loader>
            <span>Loading...</span>
          </template>
        </v-btn>
      </v-card-actions>
    </v-card-text>
  </v-card>
</template>

<script>
import { mapActions } from "vuex";
export default {
  props: {
    address: { type: String, required: true },
    discordHandle: { type: String, required: true },
    githubUsername: { type: String, required: true },
    statusId: { type: Number, required: true },
    confirmationVotes: { type: Number, required: true },
  },
  computed: {
    statusString() {
      const statusMapping = { 0: "None", 1: "Registered", 2: "Confirmed" };
      return statusMapping[this.statusId];
    },
  },
  methods: {
    ...mapActions("contributorRegistry", ["confirmContributor"]),
    async confirm() {
      try {
        this.loading = true;
        await this.confirmContributor({
          address: this.address,
        });
      } catch (e) {
        console.error("Contributor Confirmation failed with exception: ", e);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
