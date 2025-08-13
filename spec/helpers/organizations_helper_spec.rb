require 'rails_helper'

RSpec.describe OrganizationsHelper, type: :helper do
  describe '#country_options' do
    it 'returns an array of country options' do
      options = helper.country_options

      # Test that we get an array of arrays
      expect(options).to be_an(Array)
      expect(options.first).to be_an(Array)

      # Test the format of each option
      first_option = options.first
      expect(first_option.length).to eq(2)
      expect(first_option.first).to match(/\(..\)$/) # Should end with a 2-letter code in parentheses
      expect(first_option.last).to match(/^[A-Z]{2}$/) # Should be a 2-letter code

      # Test that options are sorted
      names = options.map(&:first)
      expect(names).to eq(names.sort)

      # Test that we have a reasonable number of countries
      expect(options.length).to be > 100 # There should be more than 100 countries
    end

    it 'includes common countries with correct formats' do
      options = helper.country_options
      option_hash = options.to_h

      # Test some specific countries
      us_name = options.find { |opt| opt[1] == 'US' }&.first
      gb_name = options.find { |opt| opt[1] == 'GB' }&.first

      expect(us_name).to include('(US)')
      expect(gb_name).to include('(GB)')
    end
  end
end
