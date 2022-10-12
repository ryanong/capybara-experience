require "bundler/setup"
require "capybara/rspec"
require "capybara/experience"
require "capybara/experience/rspec"
require "capybara/spec/test_app"

Capybara.app = TestApp

Capybara.register_driver :javascript_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.javascript_driver = :javascript_test

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
