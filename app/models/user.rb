# Represents a user in the system with authentication and role-based permissions
# @attr [String] email User's email address (from Devise)
# @attr [String] encrypted_password Encrypted password (from Devise)
# @attr [String] role User's role in the system (admin, moderator, or participant)
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :site_role, dependent: :destroy

  # Gets the user's role from their site_role
  # @return [String, nil] The user's role or nil if no site_role exists
  def site_role_name
    site_role&.role
  end

  # Checks if the user has admin role
  # @return [Boolean] true if user is an admin
  def admin?
    site_role_name == "admin"
  end
end
