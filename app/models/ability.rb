# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Define abilities for the user here. For example:
  #
  #   return unless user.present?
  #   can :read, :all
  #   return unless user.admin?
  #   can :manage, :all
  #
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, published: true
  #
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

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

  def admin_abilities
    # Admins can manage everything
    can :manage, :all
  end

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

  def common_abilities
    # Public access
    can :read, Topic
    can :read, Section
  end
end
