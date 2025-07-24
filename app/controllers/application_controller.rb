class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_admin_mode
  
  private
  
  def set_admin_mode
    # Enable admin mode if mode=admin is in URL params
    if params[:mode] == 'admin'
      cookies[:admin_mode] = 'true'
    end
    
    # Set admin mode based on cookie
    @admin_mode = cookies[:admin_mode] == 'true'
  end
  
  def disable_admin_mode
    cookies.delete(:admin_mode)
    @admin_mode = false
  end
end
