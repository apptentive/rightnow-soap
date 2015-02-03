# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "rightnow-soap"
  gem.homepage = "http://github.com/apptentive/rightnow-soap"
  gem.license = "MIT"
  gem.summary = %Q{Partial wrapper for Oracle RightNow SOAP API}
  gem.description = %Q{Partial wrapper for Oracle RightNow SOAP API}
  gem.email = "m@saffitz.com"
  gem.authors = ["Michael Saffitz", "Joel Stimson"]
  gem.files = Dir.glob("lib/**/*")
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files   = ['LICENSE', 'lib/**/*.rb']
    task.options = [
      '--protected',
      '--output-dir', 'doc/yard',
      '--tag', 'format:Supported formats',
      '--tag', 'authenticated:Requires Authentication',
      '--tag', 'rate_limited:Rate Limited',
      '--markup', 'markdown',
    ]
  end
end
