# frozen_string_literal: true

class LandingPageController < ApplicationController
  include ScreenSizeConcern

  EVENTS_LIMIT = 10

  def show
    @socratic_seminars = SocraticSeminar.includes(:organization, :topics)
    @upcoming_seminars = @socratic_seminars.upcoming.limit(EVENTS_LIMIT)
    @past_seminars = @socratic_seminars.past.limit(EVENTS_LIMIT)
    render template: "landing_page/#{current_layout}/show"
  end
end
