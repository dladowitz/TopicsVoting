require 'rails_helper'

# This is a test to see if the database cleaner is working.
# Previsously there was left over data from the previous test.

RSpec.describe "Database Cleaning" do
  describe "between examples" do
    it "creates a toggle in first example" do
      toggle = create(:toggle, name: "test_toggle")
      expect(Toggle.count).to eq(1)
      expect(Toggle.first.name).to eq("test_toggle")
    end

    it "should have no toggles in second example" do
      expect(Toggle.count).to eq(0)
      expect(Toggle.find_by(name: "test_toggle")).to be_nil
    end

    it "creates a different toggle in third example" do
      toggle = create(:toggle, name: "another_toggle")
      expect(Toggle.count).to eq(1)
      expect(Toggle.first.name).to eq("another_toggle")
    end
  end
end
