class SocraticSeminar < ApplicationRecord
  has_many :topics
  has_many :sections

  validates :seminar_number, presence: true, uniqueness: true
  validates :date, presence: true
end
