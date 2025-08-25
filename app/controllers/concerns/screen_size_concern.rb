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
  # @note Uses request user agent for detection, defaults to laptop in test env
  def mobile_device?
    if Rails.env.test?
      false  # Default to laptop in tests
    else
      # :nocov:
      user_agent = request.user_agent&.downcase || ""
      /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.match?(user_agent)
      # :nocov:
    end
  end

  # Gets the current layout based on device type
  # @return [String] "mobile" or "laptop"
  def current_layout
    @current_layout ||= mobile_device? ? "mobile" : "laptop"
  end
end
