class TogglesController < ApplicationController
  protect_from_forgery with: :null_session

  def increment
    name = params[:name]
    toggle = Toggle.find_by(name: name)
    if toggle
      toggle.increment!(:count)
      render json: { success: true, count: toggle.count }
    else
      render json: { success: false, error: "Toggle not found" }, status: :not_found
    end
  end

  def sats_vs_bitcoin
    @btc_count = Toggle.find_by(name: "btc_preference")&.count || 0
    @sats_count = Toggle.find_by(name: "sats_preference")&.count || 0
  end
end
