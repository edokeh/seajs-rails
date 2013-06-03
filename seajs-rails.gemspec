# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seajs/rails/version'

Gem::Specification.new do |gem|
  gem.name          = "seajs-rails"
  gem.version       = Seajs::Rails::VERSION
  gem.authors       = ["edokeh"]
  gem.email         = ["edokeh@163.com"]
  gem.description   = %q{Integrates Sea.js into the Rails 3 Asset Pipeline.}
  gem.summary       = %q{This gem provides Sea.js support for your Rails 3 application.}
  gem.homepage      = "https://github.com/edokeh/seajs-rails"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "railties", ">= 3.1.1", "< 4.1"

  gem.requirements << "spm-chaos-build is required for 'rake assets:precompile'. See https://github.com/edokeh/spm-chaos-build"
end
