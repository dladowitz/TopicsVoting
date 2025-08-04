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

      it "allows nil links" do
        topic = build(:topic, link: nil)
        expect(topic).to be_valid
      end

      it "rejects invalid URLs" do
        topic = build(:topic, link: "not-a-url")
        expect(topic).not_to be_valid
        expect(topic.errors[:link]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "rejects URLs with invalid schemes" do
        invalid_schemes = [ "ftp://example.com", "file:///path", "javascript:alert(1)" ]
        invalid_schemes.each do |url|
          topic = build(:topic, link: url)
          expect(topic).not_to be_valid
          expect(topic.errors[:link]).to include("must be a valid HTTP or HTTPS URL")
        end
      end

      it "accepts URLs with query parameters and fragments" do
        valid_urls = [
          "https://example.com/path?param=value",
          "https://example.com/path#section",
          "https://example.com/path?param=value#section"
        ]
        valid_urls.each do |url|
          topic = build(:topic, link: url)
          expect(topic).to be_valid
        end
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

    it "does not set lnurl before creation" do
      topic = build(:topic)
      expect(topic.lnurl).to be_nil
    end
  end

  describe "callbacks" do
    describe "after_create" do
      context "with different HOSTNAME values" do
        before do
          @original_hostname = ENV["HOSTNAME"]
        end

        after do
          ENV["HOSTNAME"] = @original_hostname
        end

        it "generates lnurl with standard hostname" do
          ENV["HOSTNAME"] = "https://example.com"
          topic = create(:topic)
          expect(topic.lnurl).to start_with("lnurl")
          expect(topic.lnurl).to match(/^lnurl[0-9a-z]+$/)
        end

        it "generates lnurl with hostname containing path" do
          ENV["HOSTNAME"] = "https://example.com/app"
          topic = create(:topic)
          expect(topic.lnurl).to start_with("lnurl")
          expect(topic.lnurl).to match(/^lnurl[0-9a-z]+$/)
        end

        it "handles missing HOSTNAME" do
          ENV["HOSTNAME"] = nil
          topic = create(:topic)
          expect(topic.lnurl).to start_with("lnurl")
          expect(topic.lnurl).to match(/^lnurl[0-9a-z]+$/)
        end
      end
    end

    describe "after_update_commit" do
      let(:topic) { create(:topic) }

      it "broadcasts votes update" do
        expect {
          topic.update(votes: 5)
        }.to have_broadcasted_to("topics").with(
          id: topic.id,
          votes: 5,
          sats_received: 0
        )
      end

      it "broadcasts sats update" do
        expect {
          topic.update(sats_received: 1000)
        }.to have_broadcasted_to("topics").with(
          id: topic.id,
          votes: 0,
          sats_received: 1000
        )
      end

      it "broadcasts multiple attribute updates" do
        expect {
          topic.update(votes: 5, sats_received: 1000)
        }.to have_broadcasted_to("topics").with(
          id: topic.id,
          votes: 5,
          sats_received: 1000
        )
      end

      it "does not broadcast for other attribute updates" do
        expect {
          topic.update(name: "New Name")
        }.to have_broadcasted_to("topics").with(
          id: topic.id,
          votes: 0,
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

    it "returns 0 when there are no payments" do
      expect(topic.completed_payments_count).to eq(0)
    end

    it "returns 0 when there are only unpaid payments" do
      create(:payment, topic: topic, paid: false)
      create(:payment, topic: topic, paid: false)
      expect(topic.completed_payments_count).to eq(0)
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:topic)).to be_valid
    end

    it "creates a topic with all attributes" do
      topic = create(:topic,
        name: "Test Topic",
        link: "https://example.com",
        votes: 5,
        sats_received: 1000
      )
      expect(topic).to be_valid
      expect(topic.name).to eq("Test Topic")
      expect(topic.link).to eq("https://example.com")
      expect(topic.votes).to eq(5)
      expect(topic.sats_received).to eq(1000)
      expect(topic.lnurl).to be_present
    end
  end
end
