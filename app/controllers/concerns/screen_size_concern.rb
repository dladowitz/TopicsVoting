# Concern for handling responsive layouts based on screen size
# Provides methods for determining device type and setting appropriate layouts
module ScreenSizeConcern
  extend ActiveSupport::Concern

  included do
    helper_method :mobile_width?
    helper_method :current_layout
  end

  private

  # Determines if the current device has a mobile-width screen
  # @return [Boolean] true if screen width is <= 768px
  # @note Uses cookies to store screen width, defaults to laptop in test env
  def mobile_width?
    screen_width = if Rails.env.test?
      1024  # Default to laptop width in tests
    else
      # :nocov:
      width = cookies[:screen_width].to_i
      puts "\n>>>>>> Screen width: "
      puts "       #{width}px (#{width <= 768 ? 'mobile' : 'laptop'})\n\n"
      width
      # :nocov:
    end

    screen_width <= 768
  end

  # Gets the current layout based on screen width
  # @return [String] "mobile" or "laptop"
  def current_layout
    @current_layout ||= mobile_width? ? "mobile" : "laptop"
  end
end
