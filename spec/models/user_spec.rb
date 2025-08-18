require 'rails_helper'

RSpec.describe User, type: :model do
  describe "role methods" do
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
  end
end
