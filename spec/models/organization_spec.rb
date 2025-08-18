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

  describe 'website normalization' do
    it 'removes trailing forward slash from website URL' do
      organization = build(:organization, website: 'https://example.com/')
      organization.save
      expect(organization.website).to eq('https://example.com')
    end

    it 'handles website URLs without trailing slash' do
      organization = build(:organization, website: 'https://example.com')
      organization.save
      expect(organization.website).to eq('https://example.com')
    end

    it 'handles nil website' do
      organization = build(:organization, website: nil)
      expect { organization.save }.not_to raise_error
      expect(organization.website).to be_nil
    end

    it 'handles blank website' do
      organization = build(:organization, website: '')
      expect { organization.save }.not_to raise_error
      expect(organization.website).to eq('')
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

  describe '#seminars' do
    let(:organization) { create(:organization) }
    let!(:seminar1) { create(:socratic_seminar, organization: organization) }
    let!(:seminar2) { create(:socratic_seminar, organization: organization) }
    let!(:other_seminar) { create(:socratic_seminar) }

    it 'returns only seminars belonging to this organization' do
      expect(organization.seminars).to match_array([ seminar1, seminar2 ])
      expect(organization.seminars).not_to include(other_seminar)
    end
  end

  describe "role methods" do
    let(:organization) { create(:organization) }
    let(:admin_user) { create(:user) }
    let(:moderator_user) { create(:user) }
    let(:regular_user) { create(:user) }

    before do
      create(:organization_role, :admin, user: admin_user, organization: organization)
      create(:organization_role, :moderator, user: moderator_user, organization: organization)
    end

    describe "#users_with_role" do
      it "returns users with the specified role" do
        expect(organization.users_with_role("admin")).to contain_exactly(admin_user)
        expect(organization.users_with_role("moderator")).to contain_exactly(moderator_user)
      end

      it "returns empty relation when no users have the role" do
        expect(organization.users_with_role("invalid_role")).to be_empty
      end
    end

    describe "#admins" do
      it "returns all admin users" do
        expect(organization.admins).to contain_exactly(admin_user)
      end

      it "does not include moderators or regular users" do
        expect(organization.admins).not_to include(moderator_user)
        expect(organization.admins).not_to include(regular_user)
      end
    end

    describe "#moderators" do
      it "returns all moderator users" do
        expect(organization.moderators).to contain_exactly(moderator_user)
      end

      it "does not include admins or regular users" do
        expect(organization.moderators).not_to include(admin_user)
        expect(organization.moderators).not_to include(regular_user)
      end
    end
  end
end
