require "rails_helper"

RSpec.describe HtmlSchemas::SFBitcoinDevsSchema do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:output) { [] }
  let(:stats) do
    {
      sections_created: 0,
      sections_skipped: 0,
      sections_failed: 0,
      topics_created: 0,
      topics_skipped: 0,
      topics_failed: 0
    }
  end

  describe "#process_sections" do
    let(:html_content) do
      <<~HTML
        <h2 id="development">Development</h2>
        <ul>
          <li>Topic 1</li>
          <li><a href="https://example.com">Topic 2</a></li>
          <li>Topic 3 https://example.org</li>
          <li>
            Parent Topic
            <ul>
              <li>Nested Topic 1</li>
              <li>Nested Topic 2</li>
            </ul>
          </li>
        </ul>

        <h2 id="intro">Intro Section</h2>
        <ul>
          <li>Should be skipped</li>
        </ul>

        <h2 id="lightning-and-wallets">Lightning and Wallets</h2>
        <ul>
          <li>Wallet Topic</li>
        </ul>
      HTML
    end

    let(:doc) { Nokogiri::HTML(html_content) }
    let(:schema) { described_class.new(doc, socratic_seminar, stats, output) }

    it "processes sections and topics correctly" do
      schema.process_sections

      # Check sections were created correctly
      expect(Section.count).to eq(2)
      expect(Section.pluck(:name)).to contain_exactly(
        "Development",
        "Lightning and Wallets"
      )

      # Check topics were created with correct sections
      dev_section = Section.find_by(name: "Development")
      expect(dev_section.topics.pluck(:name)).to contain_exactly(
        "Topic 1",
        "Topic 2",
        "Topic 3",
        "Parent Topic",
        "Nested Topic 1",
        "Nested Topic 2"
      )

      wallet_section = Section.find_by(name: "Lightning and Wallets")
      expect(wallet_section.topics.pluck(:name)).to contain_exactly("Wallet Topic")

      # Check links were extracted correctly
      expect(Topic.find_by(name: "Topic 2").link).to eq("https://example.com")
      expect(Topic.find_by(name: "Topic 3").link).to eq("https://example.org")
    end

    it "skips sections in SECTIONS_TO_SKIP" do
      schema.process_sections

      expect(Section.find_by(name: "Intro Section")).to be_nil
      expect(output).to include("Skipping. Section in Skip List: Intro")
    end

    it "handles sections without ids" do
      html_without_id = <<~HTML
        <h2>No ID Section</h2>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_without_id)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      expect(Section.find_by(name: "No ID Section")).to be_nil
    end

    it "updates stats correctly" do
      schema.process_sections

      expect(stats[:sections_created]).to eq(2)
      expect(stats[:topics_created]).to eq(7)
      expect(stats[:sections_skipped]).to eq(0)
      expect(stats[:topics_skipped]).to eq(0)
    end

    context "when section already exists" do
      before do
        create(:section, name: "Development", socratic_seminar: socratic_seminar)
      end

      it "skips existing section" do
        schema.process_sections

        expect(stats[:sections_skipped]).to eq(1)
        expect(stats[:sections_created]).to eq(1)
        expect(output).to include("Skipping Section (already exists): Development")
      end
    end

    context "when topic already exists" do
      before do
        section = create(:section, name: "Development", socratic_seminar: socratic_seminar)
        create(:topic, name: "Topic 1", section: section)
      end

      it "skips existing topic" do
        schema.process_sections

        expect(stats[:topics_skipped]).to eq(1)
        expect(stats[:topics_created]).to eq(6)
        expect(output).to include("Skipping Topic (already exists): Topic 1")
      end
    end
  end

  describe "#schema_name" do
    it "returns the correct schema name" do
      schema = described_class.new(nil, nil, nil, nil)
      expect(schema.schema_name).to eq("SFBitcoinDevs")
    end
  end
end
