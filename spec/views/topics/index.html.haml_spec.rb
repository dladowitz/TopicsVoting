require 'rails_helper'

RSpec.describe "topics/laptop/index", type: :view do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }

  before do
    assign(:socratic_seminar, socratic_seminar)
    assign(:sections, [ section ])
    assign(:topics, [
      create(:topic,
        name: "First Topic",
        votes: 10,
        section: section,
        socratic_seminar: socratic_seminar
      ),
      create(:topic,
        name: "Second Topic",
        votes: 5,
        section: section,
        socratic_seminar: socratic_seminar
      )
    ])
    assign(:vote_states, {})
    allow(view).to receive(:can?).and_return(false)
  end

  context "basic layout" do
    before { render }

    it "displays the list of topics" do
      expect(rendered).to have_css(".topic-list-item", count: 2)
      expect(rendered).to have_content("First Topic")
      expect(rendered).to have_content("Second Topic")
    end

    it "shows vote counts" do
      expect(rendered).to have_css("[data-topics-target='voteCount']", text: "10")
      expect(rendered).to have_css("[data-topics-target='voteCount']", text: "5")
    end

    it "has voting buttons" do
      expect(rendered).to have_css(".vote-buttons", count: 2)
      expect(rendered).to have_css(".vote-arrow", count: 4) # 2 up + 2 down
    end

    it "shows voting instructions" do
      expect(rendered).to have_css(".voting-instructions")
      expect(rendered).to have_content("Vote for free with the Up & Down arrows")
    end
  end

  context "when topics have links" do
    before do
      assign(:topics, [
        create(:topic,
          name: "Topic with Link",
          link: "https://example.com",
          section: section,
          socratic_seminar: socratic_seminar
        )
      ])
      render
    end

    it "displays the link appropriately" do
      expect(rendered).to have_css(".topic-link")
      expect(rendered).to have_link(href: "https://example.com")
    end
  end

  context "when user can manage the seminar" do
    before do
      allow(view).to receive(:can?).with(:manage, SocraticSeminar).and_return(true)
      render
    end

    it "shows admin controls" do
      expect(rendered).to have_link("New Topic")
    end
  end

  context "with Lightning payments" do
    before { render }

    it "shows Lightning payment options" do
      expect(rendered).to have_css(".send-btc-link")
      expect(rendered).to have_css(".sats-received")
    end

    it "has sats/btc toggle" do
      expect(rendered).to have_css(".sats-btc-toggle")
      expect(rendered).to have_css("#satsBtcToggleSlider")
    end
  end

  context "Lightning Effects toggle" do
    before { render }

    it "has lightning effects toggle" do
      expect(rendered).to have_css(".lightning-effects-toggle")
      expect(rendered).to have_css("#lightningEffectsToggleSlider")
    end

    it "defaults to enabled (unchecked checkbox)" do
      expect(rendered).to have_css("#lightningEffectsToggleSlider")
      expect(rendered).not_to have_css("#lightningEffectsToggleSlider[checked]")
    end

    it "shows toggle label" do
      expect(rendered).to have_css(".toggle-label-lightning", text: "Effects")
    end
  end
end
