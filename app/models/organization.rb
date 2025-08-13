class Organization < ApplicationRecord
  validates :name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2), message: "must be a valid ISO 3166-1 alpha-2 code" }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  before_save :normalize_website_url

  def country_name
    return nil if country.blank?
    country_obj = ISO3166::Country[country]
    country_obj&.common_name || country_obj&.unofficial_names&.first
  end

  private

  def normalize_website_url
    return if website.blank?
    self.website = website.chomp("/")
  end
end
