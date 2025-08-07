module DeviceDetector
  extend ActiveSupport::Concern

  included do
    before_action :set_device_type
    layout :determine_layout
  end

  private

  def set_device_type
    @device_type = if browser.device.mobile? || browser.device.tablet?
      :mobile
    else
      :laptop
    end
  end

  def determine_layout
    case @device_type
    when :mobile
      "mobile"
    else
      "laptop"
    end
  end
end
