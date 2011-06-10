# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bull/version"

Gem::Specification.new do |s|
  s.name        = "bull"
  s.version     = Bull::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Etienne Garnier"]
  s.email       = ["garnier.etienne@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{M/Monit alternative}
  s.description = %q{Web interface to monit tool,  build as replacement for M/Monit}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
