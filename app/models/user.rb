# Represents a user in the system with authentication and role-based permissions
# @attr [String] email User's email address (from Devise)
# @attr [String] encrypted_password Encrypted password (from Devise)
# @attr [String] role User's role in the system (admin, moderator, or participant)
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Available roles for users
  # @return [Array<String>] List of valid roles
  ROLES = %w[admin moderator participant].freeze

  validates :role, inclusion: { in: ROLES }, presence: true

  # Set default role before creation
  before_validation :set_default_role, on: :create

  # Checks if the user has admin role
  # @return [Boolean] true if user is an admin
  def admin?
    role == "admin"
  end

  # Checks if the user has moderator role
  # @return [Boolean] true if user is a moderator
  def moderator?
    role == "moderator"
  end

  # Checks if the user has participant role
  # @return [Boolean] true if user is a participant
  def participant?
    role == "participant"
  end

  private

  # Sets the default role to 'participant' if no role is specified
  # @return [void]
  def set_default_role
    self.role ||= "participant"
  end
end
