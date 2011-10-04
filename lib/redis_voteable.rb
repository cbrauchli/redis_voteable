require 'active_support/dependencies'
require 'redis'
require 'redis_voteable/version'
require 'redis_voteable/voteable'
require 'redis_voteable/voter'
require 'redis_voteable/exceptions'

module RedisVoteable
  extend ActiveSupport::Concern
  
  UP_VOTERS       = "up_voters"
  DOWN_VOTERS     = "dn_voters"
  UP_VOTES        = "up_votes"
  DOWN_VOTES      = "dn_votes"
  
  mattr_accessor :redis_voteable_settings
  @@redis_voteable_settings = {
        :host => 'localhost',
        :port => '6379',
        :db => 0,
        :key_prefix => "vote:",
  }
  mattr_accessor :redis
  @@redis = Redis.new(@@redis_voteable_settings)
  
  def prefixed(sid)
    "#{@@redis_voteable_settings[:key_prefix]}#{sid}"
  end
  
  def class_key(v)
    "#{v.class.name}:#{v.id}"
  end

  module ClassMethods    
    def voteable?
      false
    end

    def voter?
      false
    end
    
    # Specify a model as voteable.
    #
    # Example:
    # class Question < ActiveRecord::Base
    #   acts_as_voteable
    # end
    def acts_as_voteable 
      include Voteable
    end

    # Specify a model as voter.
    #
    # Example:
    # class User < ActiveRecord::Base
    #   acts_as_voter
    # end
    def acts_as_voter
      include Voter
    end
  end
end
