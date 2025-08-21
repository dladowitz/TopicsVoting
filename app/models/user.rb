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
  has_many :organization_roles, dependent: :destroy
  has_many :organizations, through: :organization_roles

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

  # Gets the user's role in a specific organization
  # @param organization [Organization] The organization to check roles for
  # @return [String, nil] The user's role in the organization or nil if no role exists
  def role_in(organization)
    organization_roles.find_by(organization: organization)&.role
  end

  # Checks if the user has admin role in an organization
  # @param organization [Organization] The organization to check admin status for
  # @return [Boolean] true if user is an admin of the organization
  def admin_of?(organization)
    role_in(organization) == "admin"
  end

  # Checks if the user has moderator role in an organization
  # @param organization [Organization] The organization to check moderator status for
  # @return [Boolean] true if user is a moderator of the organization
  def moderator_of?(organization)
    role_in(organization) == "moderator"
  end

  # Checks if the user can manage a socratic seminar
  # @param seminar [SocraticSeminar] The seminar to check management permissions for
  # @return [Boolean] true if user is an admin or moderator of the seminar's organization
  def can_manage?(seminar)
    admin? || admin_of?(seminar.organization) || moderator_of?(seminar.organization)
  end
end
