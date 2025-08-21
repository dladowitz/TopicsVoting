# frozen_string_literal: true

# Represents a Socratic Seminar event where topics are discussed
# @attr [Integer] seminar_number Unique identifier for the seminar
# @attr [DateTime] date When the seminar takes place
# @attr [String] topics_list_url Optional URL to a list of topics
class SocraticSeminar < ApplicationRecord
  # @!attribute sections
  #   @return [Array<Section>] Sections that organize topics in this seminar
  has_many :sections

  # @!attribute topics
  #   @return [Array<Topic>] Topics to be discussed in this seminar, through sections
  has_many :topics, through: :sections

  # @!attribute organization
  #   @return [Organization] The organization that owns this seminar
  belongs_to :organization

  validates :seminar_number, presence: true, uniqueness: { scope: :organization_id }
  validates :date, presence: true
  validates :organization, presence: true

  scope :upcoming, -> { where("date >= ?", Time.current).order(date: :asc) }
  scope :past, -> { where("date < ?", Time.current).order(date: :desc) }
end
