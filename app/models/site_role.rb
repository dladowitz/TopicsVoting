# frozen_string_literal: true

# Represents a site-wide role assignment for a user
# @attr [User] user The user who has this role
# @attr [String] role The role assigned (currently only 'admin')
class SiteRole < ApplicationRecord
  belongs_to :user

  ROLES = %w[admin].freeze

  validates :user_id, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :role }
end
