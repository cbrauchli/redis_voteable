# spec/lib/redis_voteable_spec.rb
require File.expand_path('../../spec_helper', __FILE__)

describe "Redis Voteable" do
  before(:each) do
    @voteable = VoteableModel.create(:name => "Votable 1")
    @voter = VoterModel.create(:name => "Voter 1")
  end

  it "should create a voteable instance" do
    @voteable.class.should == VoteableModel
    @voteable.class.voteable?.should == true
  end

  it "should create a voter instance" do
    @voter.class.should == VoterModel
    @voter.class.voter?.should == true
  end

  it "should get correct vote summary" do
    @voter.up_vote(@voteable).should == true
    @voteable.total_votes.should == 1
    @voteable.tally.should == 1
    @voter.down_vote(@voteable).should == true
    @voteable.total_votes.should == 1
    @voteable.tally.should == -1
    @voter.clear_vote(@voteable).should == true
    @voteable.total_votes.should == 0
    @voteable.tally.should == 0
  end

  it "voteable should have up vote votings" do
    @voteable.up_votes.should == 0
    @voter.up_vote(@voteable)
    @voteable.up_votes.should == 1
    @voteable.voters[0].up_voted?(@voteable).should be_true
  end

  it "voter should have up vote votings" do
    @voter.up_vote_count == 0
    @voter.up_vote(@voteable)
    @voter.up_vote_count == 1
    @voter.votings[0].should == @voteable
  end

  it "voteable should have down vote votings" do
    @voteable.down_votes.should == 0
    @voter.down_vote(@voteable)
    @voteable.down_votes.should == 1
    @voteable.voters[0].up_voted?(@voteable).should be_false
    @voteable.voters[0].down_voted?(@voteable).should be_true
  end

  it "voter should have down vote votings" do
    @voter.down_vote_count.should == 0
    @voter.down_vote(@voteable)
    @voter.down_vote_count.should == 1
    @voter.votings[0].should == @voteable
  end

  describe "up vote" do
    it "should increase up votes of voteable by one" do
      @voteable.up_votes.should == 0
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
    end

    it "should increase up votes of voter by one" do
      @voter.up_vote_count.should == 0
      @voter.up_vote(@voteable)
      @voter.up_vote_count.should == 1
    end

    it "should only allow a voter to up vote a voteable once" do
      @voteable.up_votes.should == 0
      @voter.up_vote(@voteable)
      lambda { @voter.up_vote(@voteable) }.should raise_error(RedisVoteable::Exceptions::AlreadyVotedError)
      @voteable.up_votes.should == 1
    end

    it "should only allow a voter to up vote a voteable once without raising an error" do
      @voteable.up_votes.should == 0
      @voter.up_vote!(@voteable)
      @voteable.up_votes.should == 1
      lambda {
        @voter.up_vote!(@voteable).should == false
      }.should_not raise_error(RedisVoteable::Exceptions::AlreadyVotedError)
      @voteable.total_votes.should == 1
    end

    it "should change a down vote to an up vote" do
      @voter.down_vote(@voteable)
      @voteable.up_votes.should == 0
      @voteable.down_votes.should == 1
      @voteable.tally.should == -1
      @voter.up_vote_count.should == 0
      @voter.down_vote_count.should == 1
      
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voteable.down_votes.should == 0
      @voteable.tally.should == 1
      @voter.up_vote_count.should == 1
      @voter.down_vote_count.should == 0
    end

    it "should allow up votes from different voters" do
      @voter2 = VoterModel.create(:name => "Voter 2")
      @voter.up_vote(@voteable)
      @voter2.up_vote(@voteable)
      @voteable.up_votes.should == 2
      @voteable.tally.should == 2
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.up_vote(invalid_voteable) }.should raise_error(RedisVoteable::Exceptions::InvalidVoteableError)
    end

    it "should check if voter up voted voteable" do
      @voter.up_vote(@voteable)
      @voter.voted?(@voteable).should be_true
      @voter.up_voted?(@voteable).should be_true
      @voter.down_voted?(@voteable).should be_false
    end
  end

  describe "down vote" do
    it "should decrease down votes of voteable by one" do
      @voteable.down_votes.should == 0
      @voter.down_vote(@voteable)
      @voteable.down_votes.should == 1
    end

    it "should decrease down votes of voter by one" do
      @voter.down_vote_count.should == 0
      @voter.down_vote(@voteable)
      @voter.down_vote_count.should == 1
    end

    it "should only allow a voter to down vote a voteable once" do
      @voteable.down_votes.should == 0
      @voter.down_vote(@voteable)
      lambda { @voter.down_vote(@voteable) }.should raise_error(RedisVoteable::Exceptions::AlreadyVotedError)
      @voteable.down_votes.should == 1
    end

    it "should only allow a voter to down vote a voteable once without raising an error" do
      @voteable.down_votes.should == 0
      @voter.down_vote!(@voteable)
      @voteable.down_votes.should == 1
      lambda {
        @voter.down_vote!(@voteable).should == false
      }.should_not raise_error(RedisVoteable::Exceptions::AlreadyVotedError)
      @voteable.total_votes.should == 1
    end

    it "should change an up vote to a down vote" do
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voteable.down_votes.should == 0
      @voteable.tally.should == 1
      @voter.up_vote_count.should == 1
      @voter.down_vote_count.should == 0
      
      @voter.down_vote(@voteable)
      @voteable.up_votes.should == 0
      @voteable.down_votes.should == 1
      @voteable.tally.should == -1
      @voter.up_vote_count.should == 0
      @voter.down_vote_count.should == 1
    end

    it "should allow down votes from different voters" do
      @voter2 = VoterModel.create(:name => "Voter 2")
      @voter.down_vote(@voteable)
      @voter2.down_vote(@voteable)
      @voteable.down_votes.should == 2
      @voteable.tally.should == -2
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.down_vote(invalid_voteable) }.should raise_error(RedisVoteable::Exceptions::InvalidVoteableError)
    end

    it "should check if voter down voted voteable" do
      @voter.down_vote(@voteable)
      @voter.voted?(@voteable).should be_true
      @voter.up_voted?(@voteable).should be_false
      @voter.down_voted?(@voteable).should be_true
    end
  end

  describe "clear_vote" do
    it "should decrease the up votes if up voted before" do
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voter.up_vote_count.should == 1
      @voter.clear_vote(@voteable)
      @voteable.up_votes.should == 0
      @voter.up_vote_count.should == 0
    end

    it "should raise an error if voter didn't vote for the voteable" do
      lambda { @voter.clear_vote(@voteable) }.should raise_error(RedisVoteable::Exceptions::NotVotedError)
    end

    it "should not raise error if voter didn't vote for the voteable and clear_vote! is called" do
      lambda {
        @voter.clear_vote!(@voteable).should == false
      }.should_not raise_error(RedisVoteable::Exceptions::NotVotedError)
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.clear_vote(invalid_voteable) }.should raise_error(RedisVoteable::Exceptions::InvalidVoteableError)
    end
  end
end
