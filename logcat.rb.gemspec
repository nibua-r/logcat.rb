# -*- encoding: utf-8 -*-

require File.expand_path('../lib/logcat.rb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'logcat.rb'
  gem.version       = Logcatrb::VERSION
  gem.authors       = ['Renaud Aubin']
  gem.date          = Date.today
  gem.summary       = %q{A ruby utility to colorize adb logcat output.}
  gem.description   = %q{logcat.rb: adb logcat meets ruby}
  gem.license       = 'Apache License, Version 2.0'
  gem.authors       = ['Renaud AUBIN']
  gem.email         = 'root@renaud.io'
  gem.homepage      = 'https://github.com/nibua-r/logcat.rb#readme'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'ruby-terminfo', '>= 0.1.1'

  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'pry', '~> 0.9.12.2'
end
