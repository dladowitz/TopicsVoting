require 'rails_helper'
require_relative '../../../app/services/html_schemas/base'
require_relative '../../../app/services/html_schemas/cdmx_bit_devs'

RSpec.describe HtmlSchemas::CDMXBitDevsSchema do
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

  describe '#process_sections' do
    let(:html_content) do
      <<~HTML
        <h3>
          <font dir="auto" style="vertical-align: inherit;">
            <font dir="auto" style="vertical-align: inherit;">Development and Technology</font>
          </font>
        </h3>
        <ul>
          <li>
            <font dir="auto" style="vertical-align: inherit;">
              <font dir="auto" style="vertical-align: inherit;">Topic 1</font>
            </font>
          </li>
          <li>
            <font dir="auto" style="vertical-align: inherit;">
              <font dir="auto" style="vertical-align: inherit;">Topic 2 </font>
            </font>
            <a href="https://example.com">Link Text</a>
          </li>
        </ul>

        <h3>
          <font dir="auto" style="vertical-align: inherit;">
            <font dir="auto" style="vertical-align: inherit;">Lightning and Wallets</font>
          </font>
        </h3>
        <ul>
          <li>
            <font dir="auto" style="vertical-align: inherit;">
              <font dir="auto" style="vertical-align: inherit;">Wallet Topic</font>
            </font>
          </li>
        </ul>
      HTML
    end

    let(:doc) { Nokogiri::HTML(html_content) }
    let(:schema) { described_class.new(doc, socratic_seminar, stats, output) }

    it 'processes sections and topics correctly' do
      schema.process_sections

      # Check sections were created correctly
      expect(Section.count).to eq(2)
      expect(Section.pluck(:name)).to contain_exactly(
        "Development and Technology",
        "Lightning and Wallets"
      )

      # Check topics were created with correct sections
      dev_section = Section.find_by(name: "Development and Technology")
      expect(dev_section.topics.pluck(:name)).to contain_exactly(
        "Topic 1",
        "Topic 2"
      )

      wallet_section = Section.find_by(name: "Lightning and Wallets")
      expect(wallet_section.topics.pluck(:name)).to contain_exactly("Wallet Topic")

      # Check link was extracted correctly
      expect(Topic.find_by(name: "Topic 2").link).to eq("https://example.com")
    end

    it 'handles sections without font tags' do
      html_without_font = <<~HTML
        <h3>Direct Section</h3>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_without_font)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      expect(Section.find_by(name: "Direct Section")).to be_present
    end

    it 'handles single-level font tags' do
      html_single_font = <<~HTML
        <h3>
          <font dir="auto" style="vertical-align: inherit;">Single Font Section</font>
        </h3>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_single_font)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      expect(Section.find_by(name: "Single Font Section")).to be_present
    end

    it 'updates stats correctly' do
      schema.process_sections

      expect(stats[:sections_created]).to eq(2)
      expect(stats[:topics_created]).to eq(3)
      expect(stats[:sections_skipped]).to eq(0)
      expect(stats[:topics_skipped]).to eq(0)
    end

    context 'when section already exists' do
      before do
        create(:section, name: "Development and Technology", socratic_seminar: socratic_seminar)
      end

      it 'skips existing section' do
        schema.process_sections

        expect(stats[:sections_skipped]).to eq(1)
        expect(stats[:sections_created]).to eq(1)
        expect(output).to include("Skipping Section (already exists): Development and Technology")
      end
    end

    context 'when topic already exists' do
      before do
        section = create(:section, name: "Development and Technology", socratic_seminar: socratic_seminar)
        create(:topic, name: "Topic 1", section: section)
      end

      it 'skips existing topic' do
        schema.process_sections

        expect(stats[:topics_skipped]).to eq(1)
        expect(stats[:topics_created]).to eq(2)
        expect(output).to include("Skipping Topic (already exists): Topic 1")
      end
    end
  end

  describe '#schema_name' do
    it 'returns the correct schema name' do
      schema = described_class.new(nil, nil, nil, nil)
      expect(schema.schema_name).to eq("CDMXBitDevs")
    end
  end
end
