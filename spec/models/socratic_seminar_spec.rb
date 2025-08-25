# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SocraticSeminar, type: :model do
  describe "associations" do
    it { should have_many(:topics) }
    it { should have_many(:sections) }
  end

  describe "validations" do
    subject { build(:socratic_seminar) }

    it { should validate_presence_of(:seminar_number) }
    it { should validate_uniqueness_of(:seminar_number).scoped_to(:organization_id) }
    it { should validate_presence_of(:date) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:socratic_seminar)).to be_valid
    end

    it "creates unique seminar numbers" do
      seminar1 = create(:socratic_seminar)
      seminar2 = create(:socratic_seminar)
      expect(seminar1.seminar_number).not_to eq(seminar2.seminar_number)
    end
  end

  describe "dependent associations" do
    let(:socratic_seminar) { create(:socratic_seminar) }
    let!(:section) { create(:section, socratic_seminar: socratic_seminar) }
    let!(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    it "has sections" do
      expect(socratic_seminar.sections).to include(section)
    end

    it "has topics" do
      expect(socratic_seminar.topics).to include(topic)
    end
  end

  describe "topics_list_url cleaning" do
    it "removes trailing slash when creating" do
      seminar = build(:socratic_seminar)
      seminar.topics_list_url = "https://www.bitcoinbuildersf.com/builder-01/"
      seminar.save!
      expect(seminar.topics_list_url).to eq("https://www.bitcoinbuildersf.com/builder-01")
    end

    it "removes trailing slash when updating" do
      seminar = create(:socratic_seminar)
      seminar.update!(topics_list_url: "https://www.bitcoinbuildersf.com/builder-01/")
      expect(seminar.topics_list_url).to eq("https://www.bitcoinbuildersf.com/builder-01")
    end

    it "does not modify URLs without trailing slashes" do
      seminar = build(:socratic_seminar)
      seminar.topics_list_url = "https://www.bitcoinbuildersf.com/builder-01"
      seminar.save!
      expect(seminar.topics_list_url).to eq("https://www.bitcoinbuildersf.com/builder-01")
    end

    it "handles nil topics_list_url" do
      seminar = build(:socratic_seminar)
      seminar.topics_list_url = nil
      seminar.save!
      expect(seminar.topics_list_url).to be_nil
    end

    it "handles empty topics_list_url" do
      seminar = build(:socratic_seminar)
      seminar.topics_list_url = ""
      seminar.save!
      expect(seminar.topics_list_url).to eq("")
    end
  end

  describe "scopes" do
    let!(:past_seminar) { create(:socratic_seminar, date: 1.day.ago) }
    let!(:upcoming_seminar) { create(:socratic_seminar, date: 1.day.from_now) }
    let!(:future_seminar) { create(:socratic_seminar, date: 2.days.from_now) }

    describe ".upcoming" do
      it "returns seminars with dates in the future" do
        expect(described_class.upcoming).to include(upcoming_seminar, future_seminar)
        expect(described_class.upcoming).not_to include(past_seminar)
      end

      it "orders seminars by date ascending" do
        expect(described_class.upcoming.to_a).to eq([ upcoming_seminar, future_seminar ])
      end
    end

    describe ".past" do
      it "returns seminars with dates in the past" do
        expect(described_class.past).to include(past_seminar)
        expect(described_class.past).not_to include(upcoming_seminar, future_seminar)
      end

      it "orders seminars by date descending" do
        old_seminar = create(:socratic_seminar, date: 2.days.ago)
        expect(described_class.past.to_a).to eq([ past_seminar, old_seminar ])
      end
    end
  end

  describe "class methods" do
    describe ".next_seminar_number_for" do
      let(:organization) { create(:organization) }

      it "returns 1 when no seminars exist" do
        expect(SocraticSeminar.next_seminar_number_for(organization)).to eq(1)
      end

      it "returns the next number when seminars exist" do
        create(:socratic_seminar, organization: organization, seminar_number: 5)
        create(:socratic_seminar, organization: organization, seminar_number: 10)
        expect(SocraticSeminar.next_seminar_number_for(organization)).to eq(11)
      end

      it "works correctly with gaps in seminar numbers" do
        create(:socratic_seminar, organization: organization, seminar_number: 1)
        create(:socratic_seminar, organization: organization, seminar_number: 5)
        expect(SocraticSeminar.next_seminar_number_for(organization)).to eq(6)
      end
    end
  end
end
