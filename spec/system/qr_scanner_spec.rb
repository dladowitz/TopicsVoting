require "rails_helper"

RSpec.describe "QR Scanner", type: :system do
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers

  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:organization_role) { create(:organization_role, user: user, organization: organization, role: "admin") }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:topic) { create(:topic, section: section) }
  let!(:payment) { create(:payment, topic: topic, amount: 1000, paid: true) }

  before(:each) do
    driven_by(:selenium_chrome_headless)
    # Create a site role to make the user an admin
    create(:site_role, user: user, role: "admin")
    organization_role # Create the organization role

    # Mock the LightningPayoutService methods
    allow(LightningPayoutService).to receive(:can_payout?).and_return(true)
    allow(LightningPayoutService).to receive(:calculate_available_payout).and_return(1000)
  end

  before do
    login_as(user, scope: :user)
  end

  describe "payout page QR scanner" do
    before do
      visit payout_socratic_seminar_path(socratic_seminar)
    end

    it "shows QR scanner button next to BOLT11 input" do
      within ".bolt11-input-section" do
        expect(page).to have_button("Scan QR")
        expect(page).to have_css("i.fas.fa-qrcode")
      end
    end

    it "shows QR scanner modal when scan button is clicked", js: true do
      click_button "Scan QR"
      expect(page).to have_css(".qr-scanner-modal:not(.hidden)")
    end

    # it "hides QR scanner modal when close button is clicked", js: true do
    #   click_button "Scan QR"
    #   expect(page).to have_css(".qr-scanner-modal:not(.hidden)")

    #   # Click the close button and wait for the modal to be hidden
    #   find(".qr-scanner-close").click
    #   expect(page).not_to have_css(".qr-scanner-modal:not(.hidden)", wait: 5)
    # end

    it "requests camera permissions when scanning starts", js: true do
      # Mock the permissions API
      page.execute_script(<<-JS)
        navigator.permissions = {
          query: async () => ({ state: "prompt" })
        };
        navigator.mediaDevices = {
          getUserMedia: async () => new MediaStream()
        };
      JS

      click_button "Scan QR"

      # Verify video element is present and active
      within ".qr-scanner-modal" do
        expect(page).to have_css("video.qr-scanner-video")
      end
    end

    # TODO: Fix QR code scanning test
    # it "updates textarea when valid BOLT11 invoice is scanned", js: true do
    #   bolt11_invoice = "lnbc1500n1ps..."
    #
    #   # Set up mocks before clicking the button
    #   page.execute_script(<<-JS)
    #     // Mock jsQR
    #     window.jsQR = () => ({ data: "#{bolt11_invoice}" });
    #
    #     // Mock getUserMedia
    #     navigator.mediaDevices = {
    #       getUserMedia: async () => {
    #         const mockStream = {
    #           getTracks: () => [{ stop: () => {} }]
    #         };
    #         return mockStream;
    #       }
    #     };
    #   JS
    #
    #   click_button "Scan QR"
    #   expect(page).to have_css(".qr-scanner-modal:not(.hidden)")
    #
    #   # Directly call the controller's scanQRCode method
    #   page.execute_script(<<-JS)
    #     const application = window.Stimulus;
    #     const controller = application.getControllerForElementAndIdentifier(
    #       document.querySelector('[data-controller="qr-scanner"]'),
    #       'qr-scanner'
    #     );
    #     controller.scanQRCode();
    #   JS
    #
    #   # Wait for the textarea to be updated and modal to be hidden
    #   expect(page).to have_field("bolt11_invoice", with: bolt11_invoice, wait: 10)
    #   expect(page).not_to have_css(".qr-scanner-modal:not(.hidden)", wait: 10)
    # end
  end
end
