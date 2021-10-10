<template>
    <round-summary 
        :votes="votes"
        :selected="selected"
        @vote="vote"
        @close-round="closeRound"
    />
    <v-container>   
        <member-card 
            v-for="person in members"
            :key="person.address"
            :person="person"
            @select="toggleSelected"
        />
    </v-container>
</template>
<script lang="ts">
import MemberCard from '../components/Member.vue'
import RoundSummary from '../components/RoundSummary.vue'
import { Person, Member } from "@/types/Person"
import { defineComponent } from 'vue'
import { mapGetters } from 'vuex'
import { Web3Getters } from '@/types/store/Web3'


export default defineComponent({
    components: {
        MemberCard,
        RoundSummary
    },
    data: () => ({
        members: [] as Person[],
        votes: 0,
        selected: [] as string[],
        memberVotes: [] as Member[]
    }),
    computed: ({
        ...mapGetters("contributorRegistry", ["getRegisteredContributors"]),
    }), 
    methods: {
        async vote (): Promise<void> {
            console.debug('Vote');
            await this.$store.dispatch('vote/vote', {
                roundId: 0,
                addressesFor: this.selected,
                addressFrom: this.$store.getters[`web3/${Web3Getters.getActiveAccount}`],
            })
        },

        async closeRound (): Promise<void> {
            console.debug('Close Round');
            await this.$store.dispatch('vote/closeRound', {
                roundId: 0,
                address: this.$store.getters[`web3/${Web3Getters.getActiveAccount}`],
            })
        },

        toggleSelected (name: string): void {
            if (this.selected.includes(name)) {
                this.selected = this.selected.filter(s => s !== name);
            } else {
                this.selected.push(name);
            }
            console.debug({ selected: this.selected })
        },

        async getMemberVotes (): Promise<void> {
            this.memberVotes = await this.$store.dispatch(
                'vote/getVotes', { roundId: 0, _for: this.selected }
            );
        },

        getMembers (): Person[] {
            const registeredMembers: Member[] = this.getRegisteredContributors
                .filter((cont: { statusId: number }) => cont.statusId === 2); 

            const _members = registeredMembers.map(member => ({
                ...member,
                name: member.discordHandle || member.githubUsername,
                registered: new Date(),
                votes: this.memberVotes.find(mv => mv.address === member.address) ?? 0,
                })
            )

            console.debug({ _members })

        return _members.sort((a, b) => b.votes - a.votes);
    }},
    async mounted(): Promise<void> {
        await this.$store.dispatch('vote/getContract');
        await this.getMemberVotes();
        const _members = this.getMembers();
        this.members = _members;
        this.votes = _members.reduce((acc: number, current: Person) => acc + current.votes, 0)
    }   
})
</script>