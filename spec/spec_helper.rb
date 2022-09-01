require "bundler/setup"
Bundler.setup

require "rightnow"
require "webmock/rspec"
require "vcr"
require "pry"

RSpec.configure do |config|
  # some (optional) config here
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures"
  c.hook_into :webmock
end
