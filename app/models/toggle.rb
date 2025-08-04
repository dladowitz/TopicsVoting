class Toggle < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
