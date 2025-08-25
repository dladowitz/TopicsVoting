# Concern for handling responsive layouts based on device type
# Provides methods for determining device type and setting appropriate layouts
module ScreenSizeConcern
  extend ActiveSupport::Concern

  included do
    helper_method :mobile_device?
    helper_method :current_layout
  end

  private

  # Determines if the current device is a mobile device
  # @return [Boolean] true if device is mobile
  # @note Uses cookies to store device type, defaults to laptop in test env
  def mobile_device?
    device_type = if Rails.env.test?
      "laptop"  # Default to laptop in tests
    else
      # :nocov:
      cookies[:device_type] || "laptop"
      # :nocov:
    end

    device_type == "mobile"
  end

  # Gets the current layout based on device type
  # @return [String] "mobile" or "laptop"
  def current_layout
    @current_layout ||= mobile_device? ? "mobile" : "laptop"
  end
end
