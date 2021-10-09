<template>
    <v-card :class="`my-3 ${selected ? 'border' : null}`">
        <v-container id="card-container">
            <v-row align="center">
                <v-col cols="2">
                    <v-row justify="center">
                        <v-img
                            :alt="`Photo of ${name}`"
                            :src="image"
                        />
                    </v-row>
                </v-col>
                <v-col cols="6">
                    <v-card-title primary-title>
                        {{ name }}
                    </v-card-title>
                    <v-divider class="ml-3"/>                    
                    <v-card-title primary-title>
                        Registered Since: {{ registered.toISOString().substring(0, 10) }}
                    </v-card-title>
                    <v-row class="ml-1" justify="start" align="center">
                        <v-col cols="1">
                            <a :href="`https://discordapp.com/users/${person.discordHandle}`"><v-icon>mdi-discord</v-icon></a>
                        </v-col>
                        <v-col cols="1">
                            <a :href="`https://github.com/${person.githubUsername}`"><v-icon>mdi-github</v-icon></a>
                        </v-col>
                    </v-row>                 
                </v-col>
                <v-col cols="4">
                    <v-row justify="center" align="center">
                        <v-card-title primary-title>
                            {{ votes }} Votes
                        </v-card-title>
                        <v-btn
                            :color="selected ? 'warning' : 'success'"
                            @click="select"
                            >
                            {{ selected ? 'Remove' : 'Add' }}
                            </v-btn>
                    </v-row>
                </v-col>                
            </v-row>
        </v-container>
    </v-card>
</template>
<script setup lang="ts">
import { onMounted, ref, toRefs } from "vue";
import { Person } from "@/types/Person"
import { apiCall } from '@/composables';

const props = defineProps({
    person: {
        type: Object as () => Person,
        required: true
    }
})

const { name, votes, registered } = toRefs(props.person);

let image = ref('');
const selected = ref(false);
const emit = defineEmits(['select'])

const select = (): void => {
    selected.value = !selected.value;
    emit('select', props.person.address);
};

onMounted(async () => {
    const _image = await apiCall('https://dog.ceo/api/breeds/image/random');
    image.value = _image.message;
})

</script>
<style scoped lang="scss">
.border {
    border: 1px orange solid !important;
    transition: 0.5s;
}
a {
    text-decoration: none !important;
}
</style>