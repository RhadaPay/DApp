<template>
    <v-card class="my-3">
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
                            <v-icon>mdi-discord</v-icon>
                        </v-col>
                        <v-col cols="1">
                            <v-icon>mdi-github</v-icon>
                        </v-col>
                    </v-row>                 
                </v-col>
                <v-col cols="4">
                    <v-row justify="center" align="center">
                        <v-card-title primary-title>
                            {{ votes }} Votes
                        </v-card-title>
                        <v-btn color="success">Vote</v-btn>
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

onMounted(async () => {

    const _image = await apiCall('https://dog.ceo/api/breeds/image/random');
    
    console.debug({_image, props: props.person });
    image.value = _image.message;
})

</script>