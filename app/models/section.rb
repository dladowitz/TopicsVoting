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
end
