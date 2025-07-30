require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe "associations" do
    it { should belong_to(:socratic_seminar) }
    it { should belong_to(:section) }
    it { should have_many(:payments) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "defaults" do
    it "sets votes to 0 by default" do
      topic = build(:topic)
      expect(topic.votes).to eq(0)
    end

    it "sets sats_received to 0 by default" do
      topic = build(:topic)
      expect(topic.sats_received).to eq(0)
    end
  end
end 