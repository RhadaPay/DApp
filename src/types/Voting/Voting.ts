/**
 * Interface for the voting module.
 * In general we can keep this fairly lightweight from our side, the basic 
 * requirements of a voting system are proposals and votes.
 * Note that we do not specify anything complex like voting strategies or weighting here.
 * 
 * If we nest votes inside proposals, then a lot of the context can be inferred.
 * A question then is whether a vote signifies
 * 
 * @questions 
 * -----------
 * Should proposals be linked to Organisations?
 * What methods are needed?
 * Should async methods (likely API calls) return responses?
 */

export enum Status {
    Open,
    Accepted,
    Rejected,
}

export interface Vote {
    id: string;
    timestamp: string;
    user: string;
}

export interface Proposal {
    id: string;
    description: string;
    votesFor: Vote[];
    votesAgainst: Vote[];
    status: Status;
    deadline: string;

    // methods, initial ideas - might change
    castVoteFor(this: Proposal, user: string): Promise<void>;
    castVoteAgainst(this: Proposal, user: string): Promise<void>;
    updateStatus(this: Proposal, status: Status): Promise<void>;
}

