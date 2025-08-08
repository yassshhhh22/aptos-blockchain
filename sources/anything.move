module MyModule::VotingPoll {
    
    use aptos_framework::signer;
    use std::vector;
    
    /// Error codes
    const E_POLL_NOT_ACTIVE: u64 = 1;
    const E_ALREADY_VOTED: u64 = 2;
    
    /// Struct representing a voting poll
    struct Poll has key, store {
        yes_votes: u64,  // Number of yes votes
        no_votes: u64,   // Number of no votes
        is_active: bool, // Whether the poll is still active
    }
    
    /// Tracks if an address has already voted
    struct HasVoted has key {
        polls: vector<address>, // Polls the user has voted on
    }
    
    /// Function to create a new voting poll
    public fun create_poll(creator: &signer) {
        let poll = Poll {
            yes_votes: 0,
            no_votes: 0,
            is_active: true,
        };
        move_to(creator, poll);
    }
    
    /// Function for users to vote on a poll
    public fun vote(voter: &signer, poll_owner: address, vote_yes: bool) acquires Poll, HasVoted {
        let voter_addr = signer::address_of(voter);
        
        // Get the poll
        let poll = borrow_global_mut<Poll>(poll_owner);
        
        // Check if the poll is active
        assert!(poll.is_active, E_POLL_NOT_ACTIVE);
        
        // Initialize HasVoted if it doesn't exist
        if (!exists<HasVoted>(voter_addr)) {
            move_to(voter, HasVoted { polls: vector::empty() });
        };
        
        // Check if the voter has already voted
        let has_voted = borrow_global_mut<HasVoted>(voter_addr);
        assert!(!vector::contains(&has_voted.polls, &poll_owner), E_ALREADY_VOTED);
        
        // Record that this user has voted
        vector::push_back(&mut has_voted.polls, poll_owner);
        
        // Update vote count
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        }
    }
}
