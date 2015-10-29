#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task "default" => "spec"

task :console do
  require 'irb'
  require 'irb/completion'
  require 'searchlight'
  ARGV.clear
  IRB.start
end

desc "Mutation test with mutant gem. Provide scope, eg: Searchlight::Search or Searchlight::Options#excluding_empties"
task :mutant do
  scope = ENV.fetch("SCOPE") {
    puts "Must set SCOPE env variable, eg `SCOPE=Searchlight::Search`"
    exit
  }

  ARGV.clear
  command = "mutant --include lib --require searchlight --use rspec #{scope}"
  begin
    exec(command)
  rescue Errno::ENOENT
    puts "Could not find mutant executable - please install gem 'mutant-rspec'"
    puts "(Not included as a test dependency because it breaks CI; mutant only works with Ruby > 2.1.0"
  end
end
