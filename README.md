RedisVoteable
=============

`RedisVoteable` is an extension for building a simple voting system for Rails
applications. It does not need to be used with any ORM in particular, however
classes in which it is used must define an `id` method. Also, only the
ActiveSupport library from Rails is used.

Installation
------------

Add RedisVoteable to your Gemfile

    gem 'redis_voteable'

afterwards execute

    bundle install

and you're done.

Configuration
-------------

By default, RedisVoteable's settings are

    redis_voteable_settings = {
      :host       => 'localhost',
      :port       => '6379',
      :db         => 0,
      :key_prefix => 'vote:'
    }

If you'd like to override any of the settings, just add a line like the
following one to a config file or initializer.

    RedisVoteable::redis_voteable_settings = { 
      :db         => 4,
      :key_prefix => 'voterecord:'
    }

Usage
-----

Note that in this example an ActiveRecord model is used, however, any other
ORM will do, as long as the object defines an `id` method. Also, for a couple
of methods, a `find` or `get` method is required. I'll point those out below.

    # Specify a voteable model.
    class Option < ActiveRecord::Base
      include RedisVoteable
      acts_as_voteable
    end
    
    # Specify a voter model.
    class User < ActiveRecord::Base
      include RedisVoteable
      acts_as_voter
    end
    
    # Votes up the question by the user.
    # If the user already voted the question up then an AlreadyVotedError is raised.
    # If the same user already voted the question down then the vote is changed to an up vote.
    user.up_vote(question)
    
    # Votes the question up, but without raising an AlreadyVotedError when the user
    # already voted the question up (it just ignores the vote and returns false).
    user.up_vote!(question)
    
    user.down_vote(question)
    user.down_vote!(question)
    
    # Clears a already done vote by an user.
    # If the user didn't vote for the question then a NotVotedError is raised.
    user.clear_vote(question)

    # Does not raise a NotVotedError if the user didn't vote for the question
    # (it just ignores the unvote and returns false).
    user.clear_vote!(question)
    
    # If you'd prefer, unvote is an alias for clear_vote.
    user.unvote(question)
    user.unvote!(question)
    
    # The number of up votes for this question.
    question.up_votes

    # The number of down votes for this question.
    question.down_votes
    
    # The total number of votes for this question.
    question.total_votes

    # The number of up votes the user has cast.
    user.up_votes

    # The number of down votes the user has cat.
    user.down_votes
    
    # The total number of votes the user has cast.
    user.total_votes
    
    # up votes - down votes (may also be negative if there are more down votes than up votes)
    question.tally
    
    # The lower bound of the Wilson confidence interval. The default value for
    # z is 1.4395314800662002, which estimates bounds with 85% confidence.
    # The value can be modified in lib/voteable.rb.
    # See http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Wilson_score_interval
    # and: http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
    question.confidence
    
    # The upper bound of the Wilson confidence interval.
    question.confidence(:upper)
    
    # Returns true if the question was voted by the user
    user.voted?(question)

    # Returns true if the question was up voted by the user, false otherwise
    user.up_voted?(question)

    # Returns true if the question was down voted by the user, false otherwise
    user.down_voted?(question)
    
    # Returns :up, :down, or nil depending on how the user voted
    user.vote_value?(question)

    # Access voted voteables through voter (slow)
    voteable = user.voteables.first
    voteable.up_voted?(user) # true if up voted by user, false otherwise
    voteable.vote_value?(user) # returns :up, :down, or nil if user didn't vote on voteable

    # Access votings through voteable (slow)
    voter = question.voters.first
    voter.up_voted?(question) # true if up voted question, false otherwise
    voter.vote_value?(question) # returns :up, :down, or nil if voter didn't vote on question
    
TO DO:
------

* Add support for getting raw voteable and voter arrays, which would save time
  by not instantiating every object.

* (Related to the next point.) Automatic ranking of voteables. Consider using a sorted set in redis.

* Add some sort of namespacing/grouping support. That way, `voteables` could
  be grouped and ranked within their group. An example use case would be users
  voting on many options to multiple questions. The options would be grouped
  by the question to which they belonged and could be easily ranked for a
  question. Could use sorted set to store grouping and rankings within
  groupings, but that may not be practical. Could also store the keys of all
  of the voteables in a grouping in a set on Redis and rank them in Ruby,
  which makes it possible to rank by Wilson confidence score.

Copyright © 2011 Chris Brauchli, released under the MIT license