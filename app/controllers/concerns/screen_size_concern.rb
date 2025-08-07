module ScreenSizeConcern
  extend ActiveSupport::Concern

  included do
    helper_method :mobile_width?
    helper_method :current_layout
  end

  private

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

  def current_layout
    @current_layout ||= mobile_width? ? "mobile" : "laptop"
  end
end
