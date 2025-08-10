# Represents a section within a Socratic Seminar that groups related topics
# @attr [String] name The name of the section
# @attr [Integer] socratic_seminar_id ID of the seminar this section belongs to
class Section < ApplicationRecord
  # @!attribute socratic_seminar
  #   @return [SocraticSeminar] The seminar this section belongs to
  belongs_to :socratic_seminar

  # @!attribute topics
  #   @return [Array<Topic>] The topics that belong to this section
  has_many :topics
end
