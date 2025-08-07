require 'capybara/rspec'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    # Set a larger window size for system tests
    driven_by(:selenium_chrome_headless) do |options|
      # Set a default window size that's definitely "laptop" size
      options.add_argument("--window-size=1920,1080")
    end
  end
end
