# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_voteable/version"

Gem::Specification.new do |s|
  s.name        = "redis_voteable"
  s.version     = RedisVoteable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Brauchli"]
  s.email       = ["cbrauchli@gmail.com"]
  s.date        = "2011-09-30"
  s.homepage    = "http://github.com/cbrauchli/redis_voteable"
  s.summary     = %q{Simple vote management with Redis used as the backend.}
  s.description = %q{A Redis-backed voting extension for Rails applications. }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Dependencies
  s.add_dependency "redis", "~> 2.2.0"
  s.add_dependency "activesupport"
  
  # For development only
  s.add_development_dependency "activerecord", "~> 3.0.0"
  s.add_development_dependency "sqlite3-ruby", "~> 1.3.0"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rspec", "~> 2.0.0"
  s.add_development_dependency "database_cleaner", "~> 0.6.7"
end
