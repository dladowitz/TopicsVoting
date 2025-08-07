require 'rails_helper'

RSpec.describe "topics/show", type: :view do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:topic) do
    create(:topic,
      name: "Sample Topic",
      link: "https://example.com",
      votes: 15,
      lnurl: "lnurl1dp68gurn8ghj7etwda6kw6pddphh2mny94jx2um5d9hx2epwdenhymmt94n8yet99eshqup0d3h82unv94cxz7f0xyev4ury",
      section: section,
      socratic_seminar: socratic_seminar
    )
  end

  before do
    assign(:socratic_seminar, socratic_seminar)
    assign(:topic, topic)
    assign(:admin_mode, false)
  end

  context "basic layout" do
    before { render }

    it "displays the topic details" do
      expect(rendered).to have_css(".topic-title", text: "Sample Topic")
      expect(rendered).to have_content("Votes: 15")
    end

    it "shows the link" do
      expect(rendered).to have_css(".topic-link-show")
      expect(rendered).to have_link(href: "https://example.com")
    end

    it "shows current status" do
      expect(rendered).to have_css(".current-status")
      expect(rendered).to have_css(".current-status-title")
      expect(rendered).to have_css(".sats-received-row")
    end
  end

  context "Lightning payment features" do
    before { render }

    it "shows LNURL payment options" do
      expect(rendered).to have_css(".vote-using-lnurl")
      expect(rendered).to have_css(".copy-lnurl")
      expect(rendered).to have_button("Copy")
    end

    it "displays the LNURL" do
      expect(rendered).to have_css(".lnurl-text", text: topic.lnurl)
    end

    it "shows QR code" do
      expect(rendered).to have_css("img[src*='qrserver']")
    end
  end

  context "when in admin mode" do
    before do
      assign(:admin_mode, true)
      render
    end

    it "shows admin controls" do
      expect(rendered).to have_link("Edit")
      expect(rendered).to have_button("Delete")
    end
  end

  context "when topic has no link" do
    before do
      topic.update(link: nil)
      render
    end

    it "does not display link section" do
      expect(rendered).not_to have_css(".topic-link-row")
    end
  end

  context "when topic has no LNURL" do
    before do
      topic.update(lnurl: nil)
      render
    end

    it "does not show Lightning payment options" do
      expect(rendered).not_to have_css(".vote-using-lnurl")
      expect(rendered).not_to have_css(".copy-lnurl")
    end
  end

  it "has navigation" do
    render
    expect(rendered).to have_css(".back-to-topic-list")
    expect(rendered).to have_link("<- Back To Topics")
  end
end
