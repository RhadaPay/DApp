<template>
    <v-card>
        <v-card-title primary-title>
            Voting Summary for Round {{ round }}
        </v-card-title>
        <v-divider/>
        <v-card-text>
            Votes {{ props.votes }}
        </v-card-text>
        <v-card-text>
            Round ends in {{ when }}
        </v-card-text>        
    </v-card>
</template>
<script setup lang="ts">
import { ref, PropType } from 'vue';
const props = defineProps({
    votes: Number as PropType<number>
})

const round = ref(1);
const when = ref('3 Days');
</script>