require 'rails_helper'

RSpec.describe Toggle, type: :model do
  describe "validations" do
    subject { build(:toggle) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "defaults" do
    it "sets count to 0 by default" do
      toggle = Toggle.new(name: "test_toggle")
      expect(toggle.count).to eq(0)
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:toggle)).to be_valid
    end
  end
end
