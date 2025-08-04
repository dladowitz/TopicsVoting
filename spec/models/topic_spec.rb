require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe "associations" do
    it { should belong_to(:socratic_seminar) }
    it { should belong_to(:section) }
    it { should have_many(:payments) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }

    context "link validation" do
      it "allows valid http URLs" do
        topic = build(:topic, link: "http://example.com")
        expect(topic).to be_valid
      end

      it "allows valid https URLs" do
        topic = build(:topic, link: "https://example.com")
        expect(topic).to be_valid
      end

      it "allows blank links" do
        topic = build(:topic, link: "")
        expect(topic).to be_valid
      end

      it "rejects invalid URLs" do
        topic = build(:topic, link: "not-a-url")
        expect(topic).not_to be_valid
        expect(topic.errors[:link]).to include("must be a valid HTTP or HTTPS URL")
      end
    end
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

  describe "callbacks" do
    describe "after_create" do
      it "sets lnurl after creation" do
        topic = create(:topic)
        expect(topic.lnurl).to be_present
        expect(topic.lnurl).to start_with("lnurl")
      end
    end

    describe "after_update_commit" do
      it "broadcasts topic update" do
        topic = create(:topic)
        expect {
          topic.update(votes: 5)
        }.to have_broadcasted_to("topics").with(
          id: topic.id,
          votes: 5,
          sats_received: 0
        )
      end
    end
  end

  describe "#completed_payments_count" do
    let(:topic) { create(:topic) }

    it "counts only paid payments" do
      create(:payment, topic: topic, paid: true)
      create(:payment, topic: topic, paid: true)
      create(:payment, topic: topic, paid: false)

      expect(topic.completed_payments_count).to eq(2)
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:topic)).to be_valid
    end
  end
end
