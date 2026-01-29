# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../lib/rubocop-yard'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed
end
