$:.push File.expand_path("../lib", __FILE__)
require "rightnow/version"

Gem::Specification.new do |s|
  s.name        = "rightnow-soap"
  s.homepage    = "https://github.com/apptentive/rightnow-soap"
  s.version     = RightNow::VERSION
  s.summary     = "Partial wrapper for Oracle RightNow SOAP API"
  s.description = "Partial wrapper for Oracle RightNow SOAP API"
  s.email       = "m@saffitz.com"
  s.authors     = ["Michael Saffitz", "Joel Stimson"]
  s.files       = Dir["LICENSE.txt", "README.md", "Gemfile", "lib/**/*.rb", "spec/**/*.rb"]
  s.license     = "MIT"

  s.add_runtime_dependency "nokogiri", "~> 1.6"
  s.add_runtime_dependency "savon", "~> 2.11"

  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rubocop", "~> 0.81"
  s.add_development_dependency "rubocop-performance", "~> 1.5"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "vcr", "~> 2.9"
  s.add_development_dependency "webmock", "~> 1.20"
  s.add_development_dependency "yard", "~> 0.8"
end
