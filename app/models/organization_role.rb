# frozen_string_literal: true

# Represents a role assignment for a user within an organization
# @attr [User] user The user who has this role
# @attr [Organization] organization The organization this role is for
# @attr [String] role The role assigned (admin or moderator)
class OrganizationRole < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  ROLES = %w[admin moderator].freeze

  validates :user_id, presence: true
  validates :organization_id, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: [ :organization_id, :role ] }
end
