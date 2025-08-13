# Base controller for the application
# @abstract Subclass and add your own functionality
class ApplicationController < ActionController::Base
  include ScreenSizeConcern

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
end
