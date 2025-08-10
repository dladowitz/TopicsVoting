# Defines authorization rules using CanCanCan
# @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
class Ability
  include CanCan::Ability

  # Initializes abilities based on user role
  # @param [User, nil] user The current user (or nil for guest)
  # @return [void]
  def initialize(user)
    # Set up guest user (not logged in)
    user ||= User.new

    if user.admin?
      admin_abilities
    elsif user.moderator?
      moderator_abilities
    elsif user.participant?
      participant_abilities(user)
    end

    # Common abilities for all users (including guests)
    common_abilities
  end

  private

  # Defines admin abilities
  # @note Admins can manage all resources
  # @return [void]
  def admin_abilities
    # Admins can manage everything
    can :manage, :all
  end

  # Defines moderator abilities
  # @note Moderators can manage topics and sections, but not admin users
  # @return [void]
  def moderator_abilities
    # Moderators can read everything
    can :read, :all

    # Topic management
    can :manage, Topic
    can :manage, Section

    # User management (except admin users)
    can :read, User
    cannot :manage, User, role: "admin"
  end

  # Defines participant abilities
  # @param [User] user The participant user
  # @note Participants can manage their own content and read public content
  # @return [void]
  def participant_abilities(user)
    # Topics
    can :read, Topic
    can :create, Topic
    can [ :update, :destroy ], Topic, user_id: user.id

    # Sections
    can :read, Section

    # Own profile
    can :read, User
    can :update, User, id: user.id
  end

  # Defines abilities common to all users (including guests)
  # @note Everyone can read topics and sections
  # @return [void]
  def common_abilities
    # Public access
    can :read, Topic
    can :read, Section
  end
end
