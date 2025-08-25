# Defines authorization rules using CanCanCan
# @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
class Ability
  include CanCan::Ability

  # Initializes abilities based on user role
  # @param [User, nil] user The current user (or nil for guest)
  # @return [void]
  def initialize(user)
    # Set up guest user (not logged in)
    @user = user.is_a?(Hash) ? User.new(user) : (user || User.new)

    if @user.respond_to?(:admin?) && @user.admin?
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

    # Users can manage topics in seminars they manage
    can :manage, Topic do |topic|
      topic.socratic_seminar.manageable_by?(@user)
    end

    # Users can manage Socratic Seminars for organizations they manage
    can :manage, SocraticSeminar do |seminar|
      seminar.manageable_by?(@user)
    end

    # All users can view Socratic Seminars
    can :read, SocraticSeminar

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
