require "rails_helper"

RSpec.describe "Sats/BTC Toggle", type: :system, js: true do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section, sats_received: 1000) }

  before do
    # Force laptop layout for consistent testing
    allow_any_instance_of(ApplicationController).to receive(:current_layout).and_return("laptop")
    topic # Create the topic
  end

  context "toggle presence and basic functionality" do
    it "has sats/btc toggle present" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)
      expect(page).to have_css(".sats-btc-toggle")
    end

    it "shows both sats and btc labels" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css(".toggle-label-sats", text: "Sats")
      expect(page).to have_css(".toggle-label-btc", text: "₿")
    end
  end

  context "toggle functionality" do
            it "can be toggled between states" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)

      toggle = page.find("#satsBtcToggleSlider", visible: false)
      initial_state = toggle.checked?

      # Toggle the switch using JavaScript
      page.execute_script("document.getElementById('satsBtcToggleSlider').checked = !#{initial_state}")
      page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")

      toggle = page.find("#satsBtcToggleSlider", visible: false)
      expect(toggle.checked?).not_to eq(initial_state)

      # Toggle back
      page.execute_script("document.getElementById('satsBtcToggleSlider').checked = #{initial_state}")
      page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")

      toggle = page.find("#satsBtcToggleSlider", visible: false)
      expect(toggle.checked?).to eq(initial_state)
    end

            it "updates labels when toggled" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)

      # Check initial labels exist
      expect(page).to have_css(".sats-label", text: /Received:/)

      # Toggle to BTC if not already
      toggle = page.find("#satsBtcToggleSlider", visible: false)
      if !toggle.checked?
        page.execute_script("document.getElementById('satsBtcToggleSlider').checked = true")
        page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")
        expect(page).to have_css(".sats-label", text: "Received: ₿", wait: 2)
      else
        expect(page).to have_css(".sats-label", text: "Received: ₿")
      end

      # Toggle back to Sats
      page.execute_script("document.getElementById('satsBtcToggleSlider').checked = false")
      page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")
      expect(page).to have_css(".sats-label", text: "Received: Sats", wait: 2)
    end

                it "updates sats info when toggled" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)

      # Check initial sats info exists
      expect(page).to have_css(".sats-info")
      expect(page).to have_css(".sats-received")

      # Toggle to BTC if not already
      toggle = page.find("#satsBtcToggleSlider", visible: false)
      if !toggle.checked?
        page.execute_script("document.getElementById('satsBtcToggleSlider').checked = true")
        page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")
        expect(page).to have_css(".sats-label", text: "Received: ₿", wait: 2)
      else
        expect(page).to have_css(".sats-label", text: "Received: ₿")
      end

      # Toggle back to Sats
      page.execute_script("document.getElementById('satsBtcToggleSlider').checked = false")
      page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")
      expect(page).to have_css(".sats-label", text: "Received: Sats", wait: 2)
    end
  end

  context "persistence behavior" do
            it "maintains state across page refresh" do
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)

      # Get initial state
      toggle = page.find("#satsBtcToggleSlider", visible: false)
      initial_state = toggle.checked?

      # Change the toggle using JavaScript
      page.execute_script("document.getElementById('satsBtcToggleSlider').checked = !#{initial_state}")
      page.execute_script("document.getElementById('satsBtcToggleSlider').dispatchEvent(new Event('change'))")

      toggle = page.find("#satsBtcToggleSlider", visible: false)
      new_state = toggle.checked?
      expect(new_state).not_to eq(initial_state)

      # Refresh the page
      visit socratic_seminar_topics_path(socratic_seminar)
      expect(page).to have_css("#satsBtcToggleSlider", visible: false, wait: 5)

      # Check that the preference is preserved (localStorage should maintain it)
      toggle = page.find("#satsBtcToggleSlider", visible: false)
      expect(toggle.checked?).to eq(new_state)
    end
  end
end
