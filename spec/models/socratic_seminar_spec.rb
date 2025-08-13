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
end
