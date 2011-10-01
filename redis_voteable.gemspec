# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_voteable/version"

Gem::Specification.new do |s|
  s.name        = "redis_voteable"
  s.version     = RedisVoteable::VERSION
  s.authors     = ["Chris Brauchli"]
  s.email       = ["cbrauchli@gmail.com"]
  s.homepage    = "http://github.com/cbrauchli"
  s.summary     = %q{Simple vote management with Redis used as the backend.}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
