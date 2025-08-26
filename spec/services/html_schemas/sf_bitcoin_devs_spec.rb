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

    it "creates parent-child relationships for nested topics" do
      schema.process_sections

      # Find the parent topic
      parent_topic = Topic.find_by(name: "Parent Topic")
      expect(parent_topic).to be_present
      expect(parent_topic.parent_topic_id).to be_nil

      # Find the nested topics
      nested_topic_1 = Topic.find_by(name: "Nested Topic 1")
      nested_topic_2 = Topic.find_by(name: "Nested Topic 2")

      expect(nested_topic_1).to be_present
      expect(nested_topic_2).to be_present

      # Verify they have the correct parent
      expect(nested_topic_1.parent_topic_id).to eq(parent_topic.id)
      expect(nested_topic_2.parent_topic_id).to eq(parent_topic.id)

      # Verify the association works
      expect(parent_topic.subtopics).to contain_exactly(nested_topic_1, nested_topic_2)
    end

    it "handles real Bitcoin Builders SF nested structure" do
      # Test with actual HTML structure from the website
      real_html = <<~HTML
        <h2 id="bitcoin-products-20-min">Bitcoin Products (20 min)</h2>
        <ul>
          <li>Block rolls out <a href="https://block.xyz/inside/block-to-roll-out-bitcoin-payments-on-square">Bitcoin payments on Square</a> at the Bitcoin 2025 Conference in Las Vegas
            <ul>
              <li>Steak N Shake reports <a href="https://bitcoinmagazine.com/news/steak-n-shake-reveals-bitcoin-payment-success-at-bitcoin-2025-conference">50% savings on processing fees when using BTC</a></li>
            </ul>
          </li>
          <li>Square is earning <a href="https://www.coindesk.com/tech/2025/05/29/square-flies-the-flag-for-the-lightning-network-with-97-yield-on-bitcoin-holdings">9.7% returns</a> on its C= Lighting Service Provider
            <ul>
              <li>Bitrefill reports <a href="https://x.com/bitrefill/status/1930217463779676334">3.5% returns</a></li>
              <li>Amboss launches <a href="https://bitcoinmagazine.com/news/amboss-launches-rails-a-self-custodial-bitcoin-yield-service">Rails</a>, a self-custody Bitcoin yield service</li>
            </ul>
          </li>
        </ul>
      HTML

      doc = Nokogiri::HTML(real_html)
      schema = described_class.new(doc, socratic_seminar, stats, output)
      schema.process_sections

      # Check that parent topics were created
      parent_1 = Topic.find_by(name: "Block rolls out Bitcoin payments on Square at the Bitcoin 2025 Conference in Las Vegas")
      parent_2 = Topic.find_by(name: "Square is earning 9.7% returns on its C= Lighting Service Provider")

      expect(parent_1).to be_present
      expect(parent_2).to be_present
      expect(parent_1.parent_topic_id).to be_nil
      expect(parent_2.parent_topic_id).to be_nil

      # Check that subtopics were created with correct parent
      subtopic_1 = Topic.find_by(name: "Steak N Shake reports 50% savings on processing fees when using BTC")
      subtopic_2 = Topic.find_by(name: "Bitrefill reports 3.5% returns")
      subtopic_3 = Topic.find_by(name: "Amboss launches Rails, a self-custody Bitcoin yield service")

      expect(subtopic_1).to be_present
      expect(subtopic_2).to be_present
      expect(subtopic_3).to be_present

      expect(subtopic_1.parent_topic_id).to eq(parent_1.id)
      expect(subtopic_2.parent_topic_id).to eq(parent_2.id)
      expect(subtopic_3.parent_topic_id).to eq(parent_2.id)
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
