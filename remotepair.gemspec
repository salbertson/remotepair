# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remotepair/version'

Gem::Specification.new do |gem|
  gem.name          = 'remotepair'
  gem.version       = Remotepair::VERSION
  gem.authors       = ['Scott Albertson']
  gem.email         = ['scott@thoughtbot.com']
  gem.description   = %q{Description goes here...}
  gem.summary       = %q{Summary goes here...}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']
  gem.add_dependency 'net-ssh'
  gem.add_dependency 'net-ssh-gateway'
  # gem.add_development_dependency("rspec")
  # gem.add_development_dependency("debugger")
end
