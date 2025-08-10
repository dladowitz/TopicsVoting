# Controller for static pages and views
class StaticController < ApplicationController
  # Renders the projector view with base URL configuration
  # @note Used for displaying topics in presentation mode
  # @return [void]
  def projector
    @url = ENV["HOSTNAME"] || request.base_url
  end
end
