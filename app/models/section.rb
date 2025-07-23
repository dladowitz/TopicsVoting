class Section < ApplicationRecord
  belongs_to :socratic_seminar
  has_many :topics
end
