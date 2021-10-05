<template>
  <v-card class="mx-auto my-12" max-width="500">
    <v-card-title>{{ address }}</v-card-title>
  </v-card>
</template>

<script>
export default {
  props: { address: { type: String, required: true } },
};
</script>
