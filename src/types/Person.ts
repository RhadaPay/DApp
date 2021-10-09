export interface Person {
    name: string;
    votes: number;
    registered: Date;
    discordHandle: string;
    githubUsername: string;
}

export interface Member {
    address:           string;
    statusId:          number;
    confirmationVotes: number;
    discordHandle:     string;
    githubUsername:    string;
}