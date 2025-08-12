class Organization < ApplicationRecord
  validates :name, presence: true
  validates :country, length: { is: 2 }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
end
