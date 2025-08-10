# Represents a toggle switch in the application
# Used for features like switching between sats and bitcoin display
# @attr [String] name Unique identifier for the toggle
# @attr [Integer] count Number of times the toggle has been switched
class Toggle < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
