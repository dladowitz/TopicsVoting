require 'rails_helper'

RSpec.describe User, type: :model do
  describe "role methods" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    describe "#admin?" do
      it "returns true when user has site_role" do
        user = create(:user, :admin)
        expect(user).to be_admin
      end

      it "returns false when user has no site_role" do
        user = create(:user)
        expect(user).not_to be_admin
      end
    end

    describe "#role_in" do
      it "returns nil when user has no role in organization" do
        expect(user.role_in(organization)).to be_nil
      end

      it "returns the role when user has a role in organization" do
        create(:organization_role, :admin, user: user, organization: organization)
        expect(user.role_in(organization)).to eq("admin")
      end
    end

    describe "#admin_of?" do
      it "returns true when user is admin of organization" do
        create(:organization_role, :admin, user: user, organization: organization)
        expect(user.admin_of?(organization)).to be true
      end

      it "returns false when user is not admin of organization" do
        create(:organization_role, :moderator, user: user, organization: organization)
        expect(user.admin_of?(organization)).to be false
      end

      it "returns false when user has no role in organization" do
        expect(user.admin_of?(organization)).to be false
      end
    end

    describe "#moderator_of?" do
      it "returns true when user is moderator of organization" do
        create(:organization_role, :moderator, user: user, organization: organization)
        expect(user.moderator_of?(organization)).to be true
      end

      it "returns false when user is not moderator of organization" do
        create(:organization_role, :admin, user: user, organization: organization)
        expect(user.moderator_of?(organization)).to be false
      end

      it "returns false when user has no role in organization" do
        expect(user.moderator_of?(organization)).to be false
      end
    end
  end
end
