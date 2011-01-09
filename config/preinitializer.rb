begin
  require 'rubygems'
  gem 'test-unit', '~> 2.0'
rescue Gem::LoadError
  puts "Could not find Test::Unit 2.0, ignoring"
end
