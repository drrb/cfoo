require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)

task :default => [:spec, :features, 'coveralls:push']
