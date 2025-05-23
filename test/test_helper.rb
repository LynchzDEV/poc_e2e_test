ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require "capybara/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml
  fixtures :all
end

# System test configuration
class ActionDispatch::SystemTestCase
  include Capybara::Minitest::Assertions
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
