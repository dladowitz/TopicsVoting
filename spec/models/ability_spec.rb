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
    let(:user) { build(:user, role: "admin") }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  describe "as moderator" do
    let(:user) { build(:user, role: "moderator") }
    let(:admin_user) { build(:user, role: "admin") }
    let(:regular_user) { build(:user, role: "participant") }

    it { is_expected.to be_able_to(:read, :all) }
    it { is_expected.to be_able_to(:manage, Topic) }
    it { is_expected.to be_able_to(:manage, Section) }

    it { is_expected.to be_able_to(:read, regular_user) }
    it { is_expected.not_to be_able_to(:manage, admin_user) }
  end

  describe "as participant" do
    let(:user) { create(:user, role: "participant") }

    context "with topics" do
      it { is_expected.to be_able_to(:read, Topic) }
      it { is_expected.to be_able_to(:create, Topic) }
    end

    context "with sections" do
      it { is_expected.to be_able_to(:read, Section) }
    end

    context "with users" do
      it { is_expected.to be_able_to(:read, User) }
      it { is_expected.to be_able_to(:update, user) }
      it { is_expected.not_to be_able_to(:update, create(:user)) }
    end
  end
end
