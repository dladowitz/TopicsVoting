# Represents a Socratic Seminar event where topics are discussed
# @attr [Integer] seminar_number Unique identifier for the seminar
# @attr [DateTime] date When the seminar takes place
# @attr [String] builder_sf_link Optional link to bitcoinbuildersf.com
class SocraticSeminar < ApplicationRecord
  # @!attribute topics
  #   @return [Array<Topic>] Topics to be discussed in this seminar
  has_many :topics

  # @!attribute sections
  #   @return [Array<Section>] Sections that organize topics in this seminar
  has_many :sections

  validates :seminar_number, presence: true, uniqueness: true
  validates :date, presence: true
end
