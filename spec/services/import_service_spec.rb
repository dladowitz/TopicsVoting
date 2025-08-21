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
      section = create(:section, name: "Test Section", socratic_seminar: socratic_seminar)
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      expect(success).to be true
      expect(output).to include("Skipping Section (already exists): Test Section")
    end

    it 'skips existing topics' do
      section = create(:section, name: "Test Section", socratic_seminar: socratic_seminar)
      topic = create(:topic, name: "Topic 1", section: section)
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
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      topic = Section.find_by(name: "Test Section").topics.find_by(name: "Topic 3")
      expect(topic.link).to eq("https://example.org")
    end

    it 'extracts links from anchor tags' do
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      topic = Section.find_by(name: "Test Section").topics.find_by(name: "Topic 2 with Link")
      expect(topic.link).to eq("https://example.com")
    end

    it 'handles nested topics' do
      success, output = described_class.import_sections_and_topics(socratic_seminar)

      section = Section.find_by(name: "Test Section")
      expect(section.topics.pluck(:name)).to include("Nested Topic 1", "Nested Topic 2")
    end
  end
end
