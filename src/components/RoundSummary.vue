<template>
    <v-card>
            <v-card-title primary-title>
                    Voting Summary for Round {{ round }}
            </v-card-title>
        <v-divider/>
                <v-card-text>
                    Votes {{ props.votes ?? 0 }}, Selected {{ selected?.length }} Members
                </v-card-text>
                <v-card-text v-if="voted">
                    You have already voted this round
                </v-card-text>                
            <v-row class="d-flex ml-0 mb-1">
                <v-card-text>
                    Round ends in {{ when }}
                </v-card-text>
                <v-card-actions>
                    <v-btn
                        @click="closeRound"
                        :disabled="!isAdmin"
                        color="warning"
                    >Close Round</v-btn>
                    <v-btn
                        @click="vote"
                        :disabled="props.selected?.length === 0"
                        color="success"
                    >Vote</v-btn>                    
                </v-card-actions>
            </v-row>
    </v-card>
</template>
<script setup lang="ts">
import { ref, PropType } from 'vue';
const props = defineProps({
    votes: Number as PropType<number>,
    selected: Array as PropType<string[]>,
})
const isAdmin = ref(true);
const round = ref(1);
const when = ref('3 Days');
const voted = ref(false);

const emits = defineEmits(['close-round', 'vote']);

const closeRound = () => emits('close-round');
const vote = () => emits('vote');
</script>