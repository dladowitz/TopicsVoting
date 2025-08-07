RSpec.shared_examples "a responsive view" do
  it "includes responsive elements" do
    expect(rendered).to have_css("[class*='desktop']")
    expect(rendered).to have_css("[class*='mobile']")
  end

  it "has touch-friendly targets" do
    expect(rendered).to have_css(".vote-button")
    expect(rendered).to have_css(".clickable")
  end
end

RSpec.shared_examples "an admin-aware view" do
  context "when in admin mode" do
    before do
      assign(:admin_mode, true)
      render
    end

    it "shows admin controls" do
      expect(rendered).to have_css(".admin-controls")
    end
  end

  context "when not in admin mode" do
    before do
      assign(:admin_mode, false)
      render
    end

    it "hides admin controls" do
      expect(rendered).not_to have_css(".admin-controls")
    end
  end
end
