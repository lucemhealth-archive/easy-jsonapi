# frozen_string_literal: true

require 'bundler/setup' # makes sure you load bundle gems instead of regular ones
require 'rack/test'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Allows all spec files to access Rack::Test
  config.include Rack::Test::Methods

  # Allows you to call describe without calling RSpec.describe
  config.expose_dsl_globally = true
end
