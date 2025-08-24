# Represents an organization that can host Socratic Seminars
# @attr [String] name The name of the organization
# @attr [String] country Optional ISO 3166-1 alpha-2 country code where the organization is based
# @attr [String] website Optional URL to the organization's website
# @attr [String] bolt12_invoice Optional Bolt12 invoice string for the organization
class Organization < ApplicationRecord
  # @!attribute socratic_seminars
  #   @return [Array<SocraticSeminar>] The seminars that belong to this organization
  has_many :socratic_seminars, dependent: :restrict_with_error
  has_many :organization_roles, dependent: :destroy
  has_many :users, -> { distinct }, through: :organization_roles

  # Gets all users with a specific role in this organization
  # @param role [String] The role to filter by
  # @return [ActiveRecord::Relation<User>] Users with the specified role
  def users_with_role(role)
    users.where(organization_roles: { role: role })
  end

  # Gets all admins of this organization
  # @return [ActiveRecord::Relation<User>] Admin users
  def admins
    users_with_role("admin")
  end

  # Gets all moderators of this organization
  # @return [ActiveRecord::Relation<User>] Moderator users
  def moderators
    users_with_role("moderator")
  end

  validates :name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2), message: "must be a valid ISO 3166-1 alpha-2 code" }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  before_save :normalize_website_url

  # Returns the full name of the organization's country
  # @return [String, nil] The common name or first unofficial name of the country, or nil if no country is set
  def country_name
    return nil if country.blank?
    country_obj = ISO3166::Country[country]
    country_obj&.common_name || country_obj&.unofficial_names&.first
  end

  def seminars
    socratic_seminars.where(organization_id: id)
  end

  private

  # Removes trailing slashes from the website URL before saving
  # @private
  def normalize_website_url
    return if website.blank?
    self.website = website.chomp("/")
  end
end
