require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'when country is present' do
      it 'allows valid ISO 3166-1 alpha-2 codes' do
        valid_codes = [ 'US', 'GB', 'DE', 'FR', 'JP' ]
        valid_codes.each do |code|
          organization = build(:organization, country: code)
          expect(organization).to be_valid
        end
      end

      it 'rejects invalid country codes' do
        invalid_codes = [ 'USA', 'XX', '12', 'INVALID' ]
        invalid_codes.each do |code|
          organization = build(:organization, country: code)
          expect(organization).not_to be_valid
          expect(organization.errors[:country]).to include('must be a valid ISO 3166-1 alpha-2 code')
        end
      end
    end

    context 'when website is present' do
      it { should allow_value('http://example.com').for(:website) }
      it { should allow_value('https://example.com').for(:website) }
      it { should_not allow_value('not-a-url').for(:website) }
    end
  end

  describe '#country_name' do
    it 'returns the full country name for valid codes' do
      organization = build(:organization, country: 'US')
      expect(organization.country_name).to eq('United States')
    end

    it 'returns nil for blank country code' do
      organization = build(:organization, country: nil)
      expect(organization.country_name).to be_nil
    end

    it 'returns nil for invalid country code' do
      organization = build(:organization, country: 'XX')
      expect(organization.country_name).to be_nil
    end
  end
end
