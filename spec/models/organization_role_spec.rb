# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationRole, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  describe "validations" do
    subject { build(:organization_role) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(OrganizationRole::ROLES) }
    it { should validate_uniqueness_of(:user_id).scoped_to([ :organization_id, :role ]) }
  end

  describe "roles" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user) }

    it "allows admin role" do
      role = build(:organization_role, :admin, user: user, organization: organization)
      expect(role).to be_valid
    end

    it "allows moderator role" do
      role = build(:organization_role, :moderator, user: user, organization: organization)
      expect(role).to be_valid
    end

    it "does not allow invalid roles" do
      role = build(:organization_role, role: "invalid", user: user, organization: organization)
      expect(role).not_to be_valid
      expect(role.errors[:role]).to include("is not included in the list")
    end
  end
end
