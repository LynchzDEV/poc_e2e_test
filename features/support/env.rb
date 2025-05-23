require 'cucumber/rails'
require 'capybara/cucumber'

# Configure database cleaner
DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :truncation

# Configure Capybara
Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless
