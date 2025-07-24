class StaticController < ApplicationController
  def projector
    @url = ENV["HOSTNAME"] || request.base_url
  end
end 