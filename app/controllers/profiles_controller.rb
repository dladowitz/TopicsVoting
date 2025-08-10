# Controller for user profile management
# @note Requires user authentication for all actions
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # Shows the current user's profile
  # @return [void]
  def show; end
end
