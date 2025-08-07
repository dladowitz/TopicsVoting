module ScreenSizeConcern
  extend ActiveSupport::Concern

  included do
    helper_method :mobile_width?
    helper_method :current_layout
  end

  private

  def mobile_width?
    screen_width = cookies[:screen_width].to_i
    puts "\n>>>>>> Screen width: "
    puts "       #{screen_width}px (#{screen_width <= 768 ? 'mobile' : 'laptop'})\n\n"

    screen_width <= 768
  end

  def current_layout
    @current_layout ||= mobile_width? ? "mobile" : "laptop"
  end

  def set_layout_by_screen_size
    if @admin_mode
      self.class.layout "laptop"
    else
      self.class.layout(mobile_width? ? "mobile" : "laptop")
    end
  end
end
