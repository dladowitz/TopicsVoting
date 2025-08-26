require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability do
  subject(:ability) { described_class.new(user) }

  describe "as guest" do
    let(:user) { nil }

    it { is_expected.to be_able_to(:read, Topic.new) }
    it { is_expected.to be_able_to(:read, Section.new) }
  end

  describe "as admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  describe "as regular user" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it { is_expected.to be_able_to(:read, Topic) }
    it { is_expected.to be_able_to(:read, Section) }
    it { is_expected.to be_able_to(:read, User) }
    it { is_expected.to be_able_to(:update, user) }
    it { is_expected.not_to be_able_to(:update, other_user) }
  end

  describe "with hash user" do
    let(:user) { { email: "test@example.com" } }

    it "creates a new user from hash" do
      expect(described_class.new(user)).to be_an(Ability)
    end
  end
end
