require 'rails_helper'

RSpec.describe "navigation/_mobile", type: :view do
  let(:socratic_seminar) { create(:socratic_seminar) }

  context "when on socratic seminar topics path" do
    before do
      allow(view).to receive(:current_page?).with(root_path).and_return(false)
      allow(view).to receive(:current_page?).with('/seminars').and_return(false)
      allow(view).to receive(:request).and_return(double(path: "/socratic_seminars/#{socratic_seminar.id}/topics"))
    end

    it "displays the home link" do
      render
      expect(rendered).to have_link("Home", href: root_path)
    end

    it "displays the submit topic button" do
      render
      expect(rendered).to have_link("Submit Topic", href: new_socratic_seminar_topic_path(socratic_seminar.id))
    end

    it "applies the correct CSS class to submit topic button" do
      render
      expect(rendered).to have_css('.submit-topic-button')
    end
  end

  context "when not on socratic seminar topics path" do
    before do
      allow(view).to receive(:current_page?).with(root_path).and_return(false)
      allow(view).to receive(:current_page?).with('/seminars').and_return(false)
      allow(view).to receive(:request).and_return(double(path: "/some/other/path"))
    end

    it "displays the home link" do
      render
      expect(rendered).to have_link("Home", href: root_path)
    end

    it "does not display the submit topic button" do
      render
      expect(rendered).not_to have_link("Submit Topic")
    end
  end

  context "when on home page" do
    before do
      allow(view).to receive(:current_page?).with(root_path).and_return(true)
      allow(view).to receive(:current_page?).with('/seminars').and_return(false)
      allow(view).to receive(:request).and_return(double(path: "/"))
    end

    it "does not display the home link" do
      render
      expect(rendered).not_to have_link("Home", href: root_path)
    end

    it "does not display the submit topic button" do
      render
      expect(rendered).not_to have_link("Submit Topic")
    end
  end
end
