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

Usage
-----

Note that in this example an ActiveRecord model is used, however, any other
ORM will do, as long as the object defines an `id` method. Also, for a couple
of methods, a `find` method is required.

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

More to come…

Copyright © 2011 Chris Brauchli, released under the MIT license