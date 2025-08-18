# Defines authorization rules using CanCanCan
# @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
class Ability
  include CanCan::Ability

  # Initializes abilities based on user role
  # @param [User, nil] user The current user (or nil for guest)
  # @return [void]
  def initialize(user)
    # Set up guest user (not logged in)
    @user = user || User.new

    if @user.admin?
      # Site-wide admin can do everything
      can :manage, :all
    end

    # All users can view organizations
    can [ :index, :show ], Organization

    # Organization admins can manage their organizations' settings and roles
    can [ :settings ], Organization do |org|
      @user.admin_of?(org)
    end
    can [ :create, :destroy ], OrganizationRole do |role|
      @user.admin_of?(role.organization)
    end

    # Common abilities for all users (including guests)
    common_abilities
  end

  private

  # Defines abilities common to all users (including guests)
  # @note Everyone can read topics and sections
  # @return [void]
  def common_abilities
    # Public access
    can :read, Topic
    can :read, Section
    can :read, User
    can :update, User, id: @user.id
  end
end
