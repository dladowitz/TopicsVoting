# frozen_string_literal: true

module OrganizationsHelper
  def country_options
    ISO3166::Country.all.sort_by { |c| c.common_name || c.unofficial_names.first }.map do |country|
      name = country.common_name || country.unofficial_names.first
      [ "#{name} (#{country.alpha2})", country.alpha2 ]
    end
  end

  def active_tab?(tab)
    @active_tab == tab ? "active" : ""
  end
end
