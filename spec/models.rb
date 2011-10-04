# spec/models.rb
class VoteableModel < ActiveRecord::Base
  include RedisVoteable
  acts_as_voteable
end

class VoterModel < ActiveRecord::Base
  include RedisVoteable
  acts_as_voter
end

class InvalidVoteableModel < ActiveRecord::Base
end
