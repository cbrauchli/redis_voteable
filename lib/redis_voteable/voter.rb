module RedisVoteable
  module Voter
    extend ActiveSupport::Concern

    included do
      # TODO: add scope
      # scope :up_voted_for, lambda { |votee| where(:_id => { '$in' =>  votee.up_voter_ids }) }
      # scope :down_voted_for, lambda { |votee| where(:_id => { '$in' =>  votee.down_voter_ids }) }
      # scope :voted_for, lambda { |votee| where(:_id => { '$in' =>  votee.voter_ids }) }
    end

    module ClassMethods
      def voter?
        true
      end
    end
    
    module InstanceMethods
      def vote(voteable, direction)
        if direction == :up
          up_vote(voteable)
        elsif direction == :down
          down_vote(voteable)
        end
      end
      
      def vote!(voteable, direction)
        if direction == :up
          up_vote!(voteable)
        elsif direction == :down
          down_vote!(voteable)
        end
      end
      
      # Up vote a +voteable+.
      # Raises an AlreadyVotedError if the voter already up voted the voteable.
      # Changes a down vote to an up vote if the the voter already down voted the voteable.
      def up_vote(voteable)
        check_voteable(voteable)

        r = redis.multi do
          redis.srem prefixed("#{class_key(voteable)}:#{DOWN_VOTERS}"), "#{class_key(self)}"
          redis.srem prefixed("#{class_key(self)}:#{DOWN_VOTES}"), "#{class_key(voteable)}"
          redis.sadd prefixed("#{class_key(voteable)}:#{UP_VOTERS}"), "#{class_key(self)}"
          redis.sadd prefixed("#{class_key(self)}:#{UP_VOTES}"), "#{class_key(voteable)}"
        end
        raise Exceptions::AlreadyVotedError.new(true) unless r[2] == 1
        true
      end

      # Up votes the +voteable+, but doesn't raise an error if the votelable was already up voted.
      # The vote is simply ignored then.
      def up_vote!(voteable)
        begin
          up_vote(voteable)
          return true
        rescue
          return false
        end
      end

      # Down vote a +voteable+.
      # Raises an AlreadyVotedError if the voter already down voted the voteable.
      # Changes an up vote to a down vote if the the voter already up voted the voteable.
      def down_vote(voteable)
        check_voteable(voteable)

        r = redis.multi do
          redis.srem prefixed("#{class_key(voteable)}:#{UP_VOTERS}"), "#{class_key(self)}"
          redis.srem prefixed("#{class_key(self)}:#{UP_VOTES}"), "#{class_key(voteable)}"
          redis.sadd prefixed("#{class_key(voteable)}:#{DOWN_VOTERS}"), "#{class_key(self)}"
          redis.sadd prefixed("#{class_key(self)}:#{DOWN_VOTES}"), "#{class_key(voteable)}"
        end
        raise Exceptions::AlreadyVotedError.new(false) unless r[2] == 1
        true
      end

      # Down votes the +voteable+, but doesn't raise an error if the votelable was already down voted.
      # The vote is simply ignored then.
      def down_vote!(voteable)
        begin
          down_vote(voteable)
          return true
        rescue
          return false
        end
      end

      # Clears an already done vote on a +voteable+.
      # Raises a NotVotedError if the voter didn't voted for the voteable.
      def clear_vote(voteable)
        check_voteable(voteable)
        
        r = redis.multi do
          redis.srem prefixed("#{class_key(voteable)}:#{DOWN_VOTERS}"), "#{class_key(self)}"
          redis.srem prefixed("#{class_key(self)}:#{DOWN_VOTES}"), "#{class_key(voteable)}"
          redis.srem prefixed("#{class_key(voteable)}:#{UP_VOTERS}"), "#{class_key(self)}"
          redis.srem prefixed("#{class_key(self)}:#{UP_VOTES}"), "#{class_key(voteable)}"
        end
        raise Exceptions::NotVotedError unless r[0] == 1 || r[2] == 1
        true
      end

      # Clears an already done vote on a +voteable+, but doesn't raise an error if
      # the voteable was not voted. It ignores the unvote then.
      def clear_vote!(voteable)
        begin
          clear_vote(voteable)
          return true
        rescue
          return false
        end
      end
      
      # Return the total number of votes a voter has cast.
      def vote_count()
        up_vote_count + down_vote_count
      end
      
      # Returns the number of upvotes a voter has cast.
      def up_vote_count()
        redis.scard prefixed("#{class_key(self)}:#{UP_VOTES}")
      end
      
      # Returns the number of downvotes a voter has cast.
      def down_vote_count()
        redis.scard prefixed("#{class_key(self)}:#{DOWN_VOTES}")
      end
      
      # Returns true if the voter voted for the +voteable+.
      def voted?(voteable)
        up_voted?(voteable) || down_voted?(voteable)
      end
      
      # Returns :up, :down, or nil.
      def vote_value?(voteable)
        return :up   if up_voted?(voteable)
        return :down if down_voted?(voteable)
        return nil
      end
      
      # Returns true if the voter up voted the +voteable+.
      def up_voted?(voteable)
        redis.sismember prefixed("#{class_key(voteable)}:#{UP_VOTERS}"), "#{class_key(self)}"
      end

      # Returns true if the voter down voted the +voteable+.
      def down_voted?(voteable)
        redis.sismember prefixed("#{class_key(voteable)}:#{DOWN_VOTERS}"), "#{class_key(self)}"
      end
      
      # Returns an array of objects that are +voter+s that voted on this 
      # +voteable+. This method can be very slow, as it constructs each
      # object. Also, it assumes that each object has a +find(id)+ method
      # defined (e.g., any ActiveRecord object).
      def votings
        up_votings | down_votings
      end
      
      def up_votings
        votings = redis.smembers prefixed("#{class_key(self)}:#{UP_VOTES}")
        votings.map do |voting|
          tmp = voting.split(':')
          tmp[0, tmp.length-1].join(':').constantize.find(tmp.last)
        end
      end
      
      def down_votings
        votings = redis.smembers prefixed("#{class_key(self)}:#{DOWN_VOTES}")
        votings.map do |voting|
          tmp = voting.split(':')
          tmp[0, tmp.length-1].join(':').constantize.find(tmp.last)
        end
      end
      
      private
      def check_voteable(voteable)
        raise Exceptions::InvalidVoteableError unless voteable.class.respond_to?("voteable?") && voteable.class.voteable?
      end
    end
  end
end
