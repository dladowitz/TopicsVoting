require "turbo-rails"

RSpec.configure do |config|
  config.include Turbo::Streams::ActionHelper, type: :system
  config.include Turbo::Streams::ActionHelper, type: :request

  config.before(:each, type: :system) do
    # Enable Turbo for system specs
    driven_by :selenium_chrome_headless
  end
end
