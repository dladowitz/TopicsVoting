# Base controller for the application
# @abstract Subclass and add your own functionality
class ApplicationController < ActionController::Base
  include ScreenSizeConcern

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_admin_mode  # Must come before set_layout_by_screen_size
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :current_layout

  # Handle CanCanCan authorization errors
  # @param [CanCan::AccessDenied] exception The authorization error that was raised
  # @return [void]
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to root_url, alert: exception.message
      end
      format.json do
        render json: { error: exception.message }, status: :forbidden
      end
    end
  end

  protected

  # Configures permitted parameters for Devise
  # @return [void]
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :role ])
  end

  private

  # Sets admin mode based on URL parameter or cookie
  # @return [void]
  def set_admin_mode
    # Enable admin mode if mode=admin is in URL params
    if params[:mode] == "admin"
      cookies[:admin_mode] = "true"
    end

    # Set admin mode based on cookie
    @admin_mode = cookies[:admin_mode] == "true"
  end

  # Disables admin mode by removing the cookie
  # @return [void]
  def disable_admin_mode
    cookies.delete(:admin_mode)
    @admin_mode = false
  end
end
