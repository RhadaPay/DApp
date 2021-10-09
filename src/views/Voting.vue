<template>
    <round-summary 
        :votes="votes"
    />
    <v-container>   
        <member-card 
            v-for="person in members"
            :key="person.name"
            :person="person"
        />
    </v-container>
</template>
<script setup lang="ts">
import { ref, onMounted, Ref } from "vue"
import MemberCard from '../components/Member.vue'
import RoundSummary from '../components/RoundSummary.vue'
import { Person } from "@/types/Person"

const members: Ref<Person[]> = ref([] as Person[])
const votes = ref(0);

const getMembers = (): Person[] => {
    const _members = [
        {
            name: 'Francesco Moca',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },
        {
            name: 'Levi Willms',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },
        {
            name: 'Kit Blake',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },
        {
            name: 'Kevin Silvergold',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },
        {
            name: 'Jordan Imran',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },
        {
            name: 'Christian Koopmann',
            votes: Math.floor(Math.random() * 100),
            registered: new Date(),  
        },        
    ];

    return _members.sort((a, b) => b.votes - a.votes);
};

onMounted(() => {
    const _members = getMembers();
    members.value = _members;
    votes.value = _members.reduce((acc: number, current: Person) => acc + current.votes, 0)
    console.debug({ votes })
}) 
</script>