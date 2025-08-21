require 'rails_helper'

RSpec.describe "Import Topics", type: :system do
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:organization_role) { create(:organization_role, user: user, organization: organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:html_content) do
    <<~HTML
      <h2 id="test-section">Test Section</h2>
      <ul>
        <li>Topic 1</li>
        <li><a href="https://example.com">Topic 2 with Link</a></li>
      </ul>
    HTML
  end

  before do
    stub_request(:get, socratic_seminar.topics_list_url)
      .to_return(status: 200, body: html_content)
    organization_role # Create the organization role
    login_as user, scope: :user
  end

  context "when user can manage the seminar" do
    before do
      allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(true)
    end

    it "allows importing topics" do
      visit socratic_seminar_import_topics_path(socratic_seminar)

      expect(page).to have_content("Import Topics")
      expect(page).to have_content(socratic_seminar.topics_list_url)

      accept_alert do
        click_button "Start Import"
      end

      expect(page).to have_content("Import completed successfully")
      expect(current_path).to eq(socratic_seminar_topics_path(socratic_seminar))
    end

    context "when import fails" do
      before do
        allow(ImportService).to receive(:import_sections_and_topics)
          .with(socratic_seminar)
          .and_return([ false, "Error: Failed to fetch URL" ])
      end

      it "shows error messages" do
        visit socratic_seminar_import_topics_path(socratic_seminar)
        accept_alert do
          click_button "Start Import"
        end

        expect(page).to have_content("Import failed")
        expect(page).to have_content("Error: Failed to fetch URL")
      end
    end
  end

  context "when user cannot manage the seminar" do
    before do
      allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(false)
    end

    it "prevents access to import page" do
      visit socratic_seminar_import_topics_path(socratic_seminar)

      expect(current_path).to eq(socratic_seminar_topics_path(socratic_seminar))
      expect(page).to have_content("not authorized")
    end
  end
end
