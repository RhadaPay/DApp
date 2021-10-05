<template>
  <div>
    <ContributorCard
      v-for="contributor in getRegisteredContributors"
      :key="contributor.address"
      v-bind="contributor"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import ContributorCard from "@/components/ContributorCard.vue";
export default {
  components: { ContributorCard },
  computed: {
    ...mapGetters("contributorRegistry", ["getRegisteredContributors"]),
  },
};
</script>
