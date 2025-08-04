require 'rails_helper'

RSpec.describe Section, type: :model do
  describe "associations" do
    it { should belong_to(:socratic_seminar) }
    it { should have_many(:topics) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:section)).to be_valid
    end
  end
end
