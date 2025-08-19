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
end
