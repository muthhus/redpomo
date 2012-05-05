require 'rubygems'
require 'bundler'

if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start
end

Bundler.require(:default, :development)

RSpec.configure do |config|
  config.mock_framework = :mocha
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: [:method, :host, :path, :body]
  }
end

require 'support/capture'