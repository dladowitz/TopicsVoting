require 'rails_helper'

RSpec.describe ImportService do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:html_content) do
    <<~HTML
      <h2 id="test-section">Test Section</h2>
      <ul>
        <li>Topic 1</li>
        <li><a href="https://example.com">Topic 2 with Link</a></li>
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
    HTML
  end

  before do
    stub_request(:get, socratic_seminar.topics_list_url)
      .to_return(status: 200, body: html_content)
  end

  describe '.import_sections_and_topics' do
    it 'imports sections and topics from HTML' do
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true
      expect(output).to include("Created Section: Test Section")
      expect(output).to include("Created Topic: Topic 1")
      expect(output).to include("Created Topic: Topic 2 with Link - link found")
      expect(output).to include("Created Topic: Topic 3 - link found")
      expect(output).not_to include("Should be skipped")
    end

    it 'skips existing sections' do
      create(:section, name: "Test Section", socratic_seminar: socratic_seminar)
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true
      expect(output).to include("Skipping Section (already exists): Test Section")
    end

    it 'skips existing topics' do
      section = create(:section, name: "Test Section", socratic_seminar: socratic_seminar)
      create(:topic, name: "Topic 1", section: section)
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true
      expect(output).to include("Skipping Topic (already exists): Topic 1")
    end

    it 'skips sections in SECTIONS_TO_SKIP' do
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true
      expect(output).to include("Skipping. Section in Skip List: Intro")
    end

    it 'handles network errors' do
      stub_request(:get, socratic_seminar.topics_list_url)
        .to_return(status: 404, body: "Not Found")
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be false
      expect(output).to include("Error: 404 Not Found")
    end

    it 'handles parsing errors' do
      stub_request(:get, socratic_seminar.topics_list_url)
        .to_return(status: 200, body: "Invalid HTML")
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true # Nokogiri handles invalid HTML gracefully
      expect(output).to include("Import complete")
    end

    it 'extracts links from text content' do
      described_class.import_sections_and_topics(socratic_seminar)

      topic = Section.find_by(name: "Test Section").topics.find_by(name: "Topic 3")
      expect(topic.link).to eq("https://example.org")
    end

    it 'extracts links from anchor tags' do
      described_class.import_sections_and_topics(socratic_seminar)

      topic = Section.find_by(name: "Test Section").topics.find_by(name: "Topic 2 with Link")
      expect(topic.link).to eq("https://example.com")
    end

    it 'handles nested topics' do
      described_class.import_sections_and_topics(socratic_seminar)

      section = Section.find_by(name: "Test Section")
      expect(section.topics.pluck(:name)).to include("Nested Topic 1", "Nested Topic 2")
    end

    context 'when encountering validation errors' do
      let(:html_with_invalid_content) do
        <<~HTML
          <h2 id="valid-section">Valid Section</h2>
          <ul>
            <li>Valid Topic</li>
            <li>Topic with Invalid Link <a href="not a valid url">Invalid Link</a></li>
          </ul>

          <h2 id="another-section">Another Section</h2>
          <ul>
            <li>Another Valid Topic</li>
          </ul>
        HTML
      end

      before do
        stub_request(:get, socratic_seminar.topics_list_url)
          .to_return(status: 200, body: html_with_invalid_content)
      end

      it 'continues importing after topic validation errors' do
        success, output = described_class.import_sections_and_topics(socratic_seminar)

        expect(success).to be true
        expect(output).to include("Created Section: Valid Section")
        expect(output).to include("Created Topic: Valid Topic")
        expect(output).to include("Failed to create Topic: Topic with Invalid Link Invalid Link (Validation failed: Link must be a valid URL or identifier)")
        expect(output).to include("Created Section: Another Section")
        expect(output).to include("Created Topic: Another Valid Topic")

        # Check stats in the output
        expect(output).to include("Topics:   1") # Failed topics count
        expect(Section.count).to eq(2)
        expect(Topic.count).to eq(2) # Only valid topics should be created
      end

      it 'tracks failed imports in statistics' do
        success, output = described_class.import_sections_and_topics(socratic_seminar)

        expect(success).to be true
        expect(output).to match(/Topics:\s+2$/) # Created topics
        expect(output).to match(/Topics:\s+1$/) # Failed topics
      end
    end

    context 'with different HTML schemas' do
      context 'with CDMXBitDevs schema' do
        let(:cdmx_html_content) do
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

        before do
          stub_request(:get, socratic_seminar.topics_list_url)
            .to_return(status: 200, body: cdmx_html_content)
        end

        it 'detects and uses CDMXBitDevs schema' do
          success, output = described_class.import_sections_and_topics(socratic_seminar)

          expect(success).to be true
          expect(output).to include("Auto-detected CDMXBitDevs schema")
          expect(output).to include("Created Section: Development and Technology")
          expect(output).to include("Created Section: Lightning and Wallets")
          expect(output).to include("Created Topic: Topic 1")
          expect(output).to include("Created Topic: Topic 2")
          expect(output).to include("Created Topic: Wallet Topic")

          # Verify sections were created
          expect(Section.count).to eq(2)
          expect(Section.pluck(:name)).to contain_exactly(
            "Development and Technology",
            "Lightning and Wallets"
          )

          # Verify topics were created with correct sections
          dev_section = Section.find_by(name: "Development and Technology")
          expect(dev_section.topics.pluck(:name)).to contain_exactly("Topic 1", "Topic 2")

          wallet_section = Section.find_by(name: "Lightning and Wallets")
          expect(wallet_section.topics.pluck(:name)).to contain_exactly("Wallet Topic")
        end

        it 'extracts links correctly from CDMXBitDevs format' do
          success, _ = described_class.import_sections_and_topics(socratic_seminar)

          expect(success).to be true
          topic = Topic.find_by(name: "Topic 2")
          expect(topic.link).to eq("https://example.com")
        end
      end

      context 'with unrecognized schema' do
        let(:unknown_html_content) do
          <<~HTML
            <div>Some random content</div>
            <p>Not matching any known schema</p>
          HTML
        end

        before do
          stub_request(:get, socratic_seminar.topics_list_url)
            .to_return(status: 200, body: unknown_html_content)
        end

        it 'falls back to SFBitcoinDevs schema' do
          success, output = described_class.import_sections_and_topics(socratic_seminar)

          expect(success).to be true
          expect(output).to include("Unable to detect specific schema, falling back to SFBitcoinDevs schema")
          expect(output).to include("Import complete")
        end
      end

      context 'with URL-based schema detection' do
        let(:simple_html_content) do
          <<~HTML
            <h2 id="section-1">Section 1</h2>
            <ul><li>Topic 1</li></ul>
          HTML
        end

        it 'detects SFBitcoinDevs schema from URL' do
          socratic_seminar.topics_list_url = "https://sfbitcoindevs.com/some-page"
          stub_request(:get, socratic_seminar.topics_list_url)
            .to_return(status: 200, body: simple_html_content)

          success, output = described_class.import_sections_and_topics(socratic_seminar)

          expect(success).to be true
          expect(output).not_to include("Auto-detected")
          expect(Section.find_by(name: "Section 1")).to be_present
        end

        it 'detects CDMXBitDevs schema from URL' do
          socratic_seminar.topics_list_url = "https://cdmxbitdevs.org/some-page"
          stub_request(:get, socratic_seminar.topics_list_url)
            .to_return(status: 200, body: simple_html_content)

          success, output = described_class.import_sections_and_topics(socratic_seminar)

          expect(success).to be true
          expect(output).not_to include("Auto-detected")
        end
      end
    end
  end
end
