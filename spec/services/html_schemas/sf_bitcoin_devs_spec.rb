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
        <h2 id="development">Development (30 mins)</h2>
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

        <h2 id="vote-on-topics">Vote on topics (5 min)</h2>
        <!-- No list here, this section should be skipped -->

        <h2 id="intro-section">Intro Section (10 minutes)</h2>
        <ul>
          <li>Intro Topic</li>
        </ul>

        <h2 id="lightning-and-wallets">Lightning and Wallets (20 mins)</h2>
        <ul>
          <li>Wallet Topic</li>
        </ul>
      HTML
    end

    let(:doc) { Nokogiri::HTML(html_content) }
    let(:schema) { described_class.new(doc, socratic_seminar, stats, output) }

    it "processes sections and topics correctly" do
      schema.process_sections

      # Check sections were created correctly with durations
      expect(Section.count).to eq(3) # Development, Lightning and Wallets, Intro Section
      expect(Section.pluck(:name)).to contain_exactly(
        "Development (30 mins)",
        "Lightning and Wallets (20 mins)",
        "Intro Section (10 minutes)"
      )

      # Check topics were created with correct sections
      dev_section = Section.find_by(name: "Development (30 mins)")
      expect(dev_section.topics.pluck(:name)).to contain_exactly(
        "Topic 1",
        "Topic 2",
        "Topic 3",
        "Parent Topic",
        "Nested Topic 1",
        "Nested Topic 2"
      )

      wallet_section = Section.find_by(name: "Lightning and Wallets (20 mins)")
      expect(wallet_section.topics.pluck(:name)).to contain_exactly("Wallet Topic")

      # Check links were extracted correctly
      expect(Topic.find_by(name: "Topic 2").link).to eq("https://example.com")
      expect(Topic.find_by(name: "Topic 3").link).to eq("https://example.org")
    end

    it "completely skips sections in SECTIONS_TO_SKIP" do
      schema.process_sections

      # Section should not be created at all
      expect(Section.find_by(name: "vote on topics (5 min)")).to be_nil
      expect(output).to include("Skipping section: Vote on topics (5 min)")
    end

    it "sets votable and payable to false for intro sections" do
      schema.process_sections

      intro_section = Section.find_by(name: "Intro Section (10 minutes)")
      expect(intro_section).to be_present
      intro_topic = intro_section.topics.find_by(name: "Intro Topic")
      expect(intro_topic).to be_present
      expect(intro_topic.votable).to be false
      expect(intro_topic.payable).to be false
    end

    it "sets votable and payable to true for non-intro sections" do
      schema.process_sections

      dev_section = Section.find_by(name: "Development (30 mins)")
      expect(dev_section).to be_present
      dev_topics = dev_section.topics
      expect(dev_topics).to be_present
      dev_topics.each do |topic|
        expect(topic.votable).to be true
        expect(topic.payable).to be true
      end
    end

    it "creates sections without ids" do
      html_without_id = <<~HTML
        <h2>No ID Section</h2>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_without_id)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      section = Section.find_by(name: "No ID Section")
      expect(section).to be_present
      expect(section.topics.count).to eq(1)
      expect(section.topics.first.name).to eq("Topic")
    end

    it "handles sections with no following list" do
      html_no_list = <<~HTML
        <h2 id="section-without-list">Section Without List</h2>
        <p>Some other content</p>
      HTML
      doc = Nokogiri::HTML(html_no_list)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      # Should create a section but with no topics since there's no list
      section = Section.find_by(name: "Section Without List")
      expect(section).to be_present
      expect(section.topics.count).to eq(0)
    end

    it "transforms section names correctly from IDs" do
      html_complex_ids = <<~HTML
        <h2 id="bitcoin-core-development">Bitcoin Core Development</h2>
        <ul><li>Topic</li></ul>
        <h2 id="lightning-network-and-payments">Lightning Network and Payments</h2>
        <ul><li>Topic</li></ul>
        <h2 id="wallet-security-and-privacy">Wallet Security and Privacy</h2>
        <ul><li>Topic</li></ul>
        <h2 id="decentralized-finance-and-defi">Decentralized Finance and Defi</h2>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_complex_ids)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      expect(Section.find_by(name: "Bitcoin Core Development")).to be_present
      expect(Section.find_by(name: "Lightning Network and Payments")).to be_present
      expect(Section.find_by(name: "Wallet Security and Privacy")).to be_present
      expect(Section.find_by(name: "Decentralized Finance and Defi")).to be_present
    end

    it "preserves 'and' in lowercase when transforming section names" do
      html_with_and = <<~HTML
        <h2 id="bitcoin-and-ethereum">Bitcoin and Ethereum</h2>
        <ul><li>Topic</li></ul>
        <h2 id="lightning-and-lightning-network">Lightning and Lightning Network</h2>
        <ul><li>Topic</li></ul>
      HTML
      doc = Nokogiri::HTML(html_with_and)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      expect(Section.find_by(name: "Bitcoin and Ethereum")).to be_present
      expect(Section.find_by(name: "Lightning and Lightning Network")).to be_present
    end

    it "handles empty list items" do
      html_empty_items = <<~HTML
        <h2 id="empty-items-section">Empty Items Section</h2>
        <ul>
          <li></li>
          <li>Valid Topic</li>
          <li>   </li>
          <li>
            <ul>
              <li>Nested Topic</li>
            </ul>
          </li>
        </ul>
      HTML
      doc = Nokogiri::HTML(html_empty_items)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      section = Section.find_by(name: "Empty Items Section")
      expect(section).to be_present

      # Should create 2 topics: the valid one and the nested one (even though parent is empty)
      expect(section.topics.count).to eq(2)
      expect(section.topics.pluck(:name)).to contain_exactly("Valid Topic", "Nested Topic")
    end

    it "handles list items with only URLs in text" do
      html_url_only = <<~HTML
        <h2 id="url-only-section">URL Only Section</h2>
        <ul>
          <li>https://example.com</li>
          <li>Topic with https://example.org in text</li>
          <li>www.example.net</li>
        </ul>
      HTML
      doc = Nokogiri::HTML(html_url_only)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      section = Section.find_by(name: "URL Only Section")
      expect(section).to be_present

      # Should only create one topic (the one with text beyond the URL)
      expect(section.topics.count).to eq(1)
      expect(section.topics.first.name).to eq("Topic with  in text")
    end

    it "handles nested lists with empty parent topics" do
      html_empty_parent = <<~HTML
        <h2 id="nested-empty-parent">Nested Empty Parent</h2>
        <ul>
          <li>
            <ul>
              <li>Orphan Child</li>
            </ul>
          </li>
          <li>
            Parent with Content
            <ul>
              <li>Child with Parent</li>
            </ul>
          </li>
        </ul>
      HTML
      doc = Nokogiri::HTML(html_empty_parent)
      schema = described_class.new(doc, socratic_seminar, stats, output)

      schema.process_sections

      section = Section.find_by(name: "Nested Empty Parent")
      expect(section).to be_present

      # Should create 3 topics: orphan child, parent with content, and child with parent
      expect(section.topics.count).to eq(3)

      orphan_child = Topic.find_by(name: "Orphan Child")
      parent_with_content = Topic.find_by(name: "Parent with Content")
      child_with_parent = Topic.find_by(name: "Child with Parent")

      expect(orphan_child).to be_present
      expect(orphan_child.parent_topic).to be_nil

      expect(parent_with_content).to be_present
      expect(parent_with_content.parent_topic).to be_nil

      expect(child_with_parent).to be_present
      expect(child_with_parent.parent_topic).to eq(parent_with_content)
    end

    it "updates stats correctly" do
      schema.process_sections

      expect(stats[:sections_created]).to eq(3) # Development, Lightning and Wallets, Intro Section
      expect(stats[:topics_created]).to eq(8)
      expect(stats[:sections_skipped]).to eq(1) # Vote on topics section is skipped
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
        create(:section, name: "Development (30 mins)", socratic_seminar: socratic_seminar)
      end

      it "skips existing section" do
        schema.process_sections

        expect(stats[:sections_skipped]).to eq(2) # Vote on topics section and Development section are skipped
        expect(stats[:sections_created]).to eq(2) # Lightning and Wallets, Intro Section (Development is skipped)
        expect(output).to include("Skipping Section (already exists): Development (30 mins)")
      end
    end

    context "when topic already exists" do
      before do
        section = create(:section, name: "Development (30 mins)", socratic_seminar: socratic_seminar)
        create(:topic, name: "Topic 1", section: section)
      end

      it "skips existing topic" do
        schema.process_sections

        expect(stats[:topics_skipped]).to eq(1)
        expect(stats[:topics_created]).to eq(7)
        expect(output).to include("Skipping Topic (already exists): Topic 1")
      end
    end
  end

  describe "#non_votable_section?" do
    let(:schema) { described_class.new(nil, nil, nil, nil) }

    it "identifies non-votable sections" do
      described_class::NON_VOTABLE_SECTIONS.each do |section_name|
        expect(schema.send(:non_votable_section?, section_name)).to be true
        expect(schema.send(:non_votable_section?, section_name.upcase)).to be true
        expect(schema.send(:non_votable_section?, "#{section_name} (20 min)")).to be true
      end
    end

    it "identifies votable sections" do
      votable_sections = [ "Development", "Lightning Network", "Bitcoin Products" ]
      votable_sections.each do |section_name|
        expect(schema.send(:non_votable_section?, section_name)).to be false
        expect(schema.send(:non_votable_section?, section_name.upcase)).to be false
        expect(schema.send(:non_votable_section?, "#{section_name} (20 min)")).to be false
      end
    end
  end

  describe "#non_payable_section?" do
    let(:schema) { described_class.new(nil, nil, nil, nil) }

    it "identifies non-payable sections" do
      described_class::NON_PAYABLE_SECTIONS.each do |section_name|
        expect(schema.send(:non_payable_section?, section_name)).to be true
        expect(schema.send(:non_payable_section?, section_name.upcase)).to be true
        expect(schema.send(:non_payable_section?, "#{section_name} (20 min)")).to be true
      end
    end

    it "identifies payable sections" do
      payable_sections = [ "Development", "Lightning Network", "Bitcoin Products" ]
      payable_sections.each do |section_name|
        expect(schema.send(:non_payable_section?, section_name)).to be false
        expect(schema.send(:non_payable_section?, section_name.upcase)).to be false
        expect(schema.send(:non_payable_section?, "#{section_name} (20 min)")).to be false
      end
    end
  end

  describe "#non_publicly_submitable_section?" do
    let(:schema) { described_class.new(nil, nil, nil, nil) }

    it "identifies non-publicly submitable sections" do
      described_class::NON_PUBLICLY_SUBMITABLE.each do |section_name|
        expect(schema.send(:non_publicly_submitable_section?, section_name)).to be true
        expect(schema.send(:non_publicly_submitable_section?, section_name.upcase)).to be true
        expect(schema.send(:non_publicly_submitable_section?, "#{section_name} (20 min)")).to be true
      end
    end

    it "identifies publicly submitable sections" do
      public_sections = [ "Development", "Lightning Network", "Bitcoin Products" ]
      public_sections.each do |section_name|
        expect(schema.send(:non_publicly_submitable_section?, section_name)).to be false
        expect(schema.send(:non_publicly_submitable_section?, section_name.upcase)).to be false
        expect(schema.send(:non_publicly_submitable_section?, "#{section_name} (20 min)")).to be false
      end
    end
  end

  describe "#normalize_section_name" do
    let(:schema) { described_class.new(nil, nil, nil, nil) }

    it "removes duration in parentheses" do
      expect(schema.send(:normalize_section_name, "Bitcoin Products (20 min)")).to eq("bitcoin products")
      expect(schema.send(:normalize_section_name, "Lightning Network (30 mins)")).to eq("lightning network")
      expect(schema.send(:normalize_section_name, "Development (5 minutes)")).to eq("development")
    end

    it "handles variations in duration format" do
      expect(schema.send(:normalize_section_name, "Section (20min)")).to eq("section")
      expect(schema.send(:normalize_section_name, "Section (20 minutes)")).to eq("section")
      expect(schema.send(:normalize_section_name, "Section (20mins)")).to eq("section")
    end

    it "handles extra whitespace" do
      expect(schema.send(:normalize_section_name, "  Bitcoin Products  (20 min)  ")).to eq("bitcoin products")
      expect(schema.send(:normalize_section_name, "Lightning Network(30mins)")).to eq("lightning network")
    end

    it "preserves section names without duration" do
      expect(schema.send(:normalize_section_name, "Bitcoin Products")).to eq("bitcoin products")
      expect(schema.send(:normalize_section_name, "Lightning Network")).to eq("lightning network")
    end

    it "handles case variations" do
      expect(schema.send(:normalize_section_name, "BITCOIN PRODUCTS (20 min)")).to eq("bitcoin products")
      expect(schema.send(:normalize_section_name, "Lightning NETWORK (30 mins)")).to eq("lightning network")
    end
  end

  describe "#schema_name" do
    it "returns the correct schema name" do
      schema = described_class.new(nil, nil, nil, nil)
      expect(schema.schema_name).to eq("SFBitcoinDevs")
    end
  end
end
