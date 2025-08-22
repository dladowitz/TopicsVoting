# frozen_string_literal: true

require "rails_helper"

RSpec.describe SectionsHelper, type: :helper do
  describe "#section_delete_warning" do
    let(:organization) { create(:organization) }
    let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
    let(:section) { create(:section, socratic_seminar: socratic_seminar) }

    context "when section has no topics" do
      it "returns basic warning message" do
        expect(helper.section_delete_warning(section)).to eq("Are you sure you want to delete this section?")
      end
    end

    context "when section has one topic" do
      before { create(:topic, section: section) }

      it "returns warning message with topic count" do
        expect(helper.section_delete_warning(section)).to eq("Are you sure you want to delete this section? This will delete 1 topic as well.")
      end
    end

    context "when section has multiple topics" do
      before { create_list(:topic, 3, section: section) }

      it "returns warning message with topics count" do
        expect(helper.section_delete_warning(section)).to eq("Are you sure you want to delete this section? This will delete 3 topics as well.")
      end
    end
  end
end
