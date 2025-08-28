# frozen_string_literal: true

# Represents a section within a Socratic Seminar that groups related topics
# @attr [String] name The name of the section
# @attr [Integer] socratic_seminar_id ID of the seminar this section belongs to
# @attr [Integer] order The display order of this section within the seminar
class Section < ApplicationRecord
  # @!attribute socratic_seminar
  #   @return [SocraticSeminar] The seminar this section belongs to
  belongs_to :socratic_seminar

  # @!attribute topics
  #   @return [Array<Topic>] The topics that belong to this section
  has_many :topics, dependent: :destroy

  validates :name, presence: true
  validates :order, presence: true

  # Default ordering by the order column
  default_scope { order(:order) }

  # Determines if a user can create topics in this section
  # @param user [User, nil] The user to check permissions for
  # @return [Boolean] true if the user can create topics in this section
  def allows_topic_creation_by?(user)
    return true if user&.admin?
    return true if user&.admin_of?(socratic_seminar.organization)
    return true if user&.moderator_of?(socratic_seminar.organization)
    allow_public_submissions
  end

  # Scope for sections where a user can create topics
  # @param user [User, nil] The user to filter sections for
  # @return [ActiveRecord::Relation] Sections where the user can create topics
  scope :available_for_topic_creation, ->(user) {
    if user.nil?
      where(allow_public_submissions: true)
    elsif user.admin?
      all
    else
      left_joins(socratic_seminar: :organization)
        .where("sections.allow_public_submissions = ? OR EXISTS (
          SELECT 1 FROM organization_roles
          WHERE organization_roles.organization_id = organizations.id
          AND organization_roles.user_id = ?
          AND organization_roles.role IN (?)
        )", true, user.id, [ "admin", "moderator" ])
    end
  }
end
