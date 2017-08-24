# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape-datadog/version'

Gem::Specification.new do |gem|
  gem.name          = "grape-datadog"
  gem.version       = Datadog::Grape::VERSION
  gem.authors       = ["Artem Chernyshev"]
  gem.email         = ["artem.0xD2@gmail.com"]
  gem.description   = %q{Datadog metrics for grape}
  gem.summary       = %q{Datadog metrics for grape}
  gem.homepage      = "https://github.com/Unix4ever/grape-datadog"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency(%q<grape>, '~>0.19.2')
  gem.add_runtime_dependency(%q<dogstatsd-ruby>, '=2.0.0')
  gem.add_development_dependency('pry-byebug')
end
