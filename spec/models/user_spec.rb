require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "validates inclusion of role in ROLES" do
      user = build(:user, role: "invalid_role")
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("is not included in the list")
    end

    it "allows valid roles" do
      User::ROLES.each do |role|
        user = build(:user, role: role)
        expect(user).to be_valid
      end
    end
  end

  describe "defaults" do
    it "sets default role to participant" do
      user = User.new
      user.valid?
      expect(user.role).to eq("participant")
    end
  end

  describe "role methods" do
    let(:user) { build(:user) }

    context "when admin" do
      before { user.role = "admin" }

      it { expect(user).to be_admin }
      it { expect(user).not_to be_moderator }
      it { expect(user).not_to be_participant }
    end

    context "when moderator" do
      before { user.role = "moderator" }

      it { expect(user).not_to be_admin }
      it { expect(user).to be_moderator }
      it { expect(user).not_to be_participant }
    end

    context "when participant" do
      before { user.role = "participant" }

      it { expect(user).not_to be_admin }
      it { expect(user).not_to be_moderator }
      it { expect(user).to be_participant }
    end
  end
end
