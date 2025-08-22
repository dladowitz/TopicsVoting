require 'rails_helper'
require_relative '../../../app/services/html_schemas/base'

RSpec.describe HtmlSchemas::BaseSchema do
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

  # Create a concrete test class since BaseSchema is abstract
  let(:test_schema_class) do
    Class.new(described_class) do
      def process_sections
        # Test implementation
      end
    end
  end

  let(:schema) { test_schema_class.new(nil, socratic_seminar, stats, output) }

  describe '#process_sections' do
    it 'raises NotImplementedError when called on base class' do
      expect { described_class.new(nil, nil, nil, nil).process_sections }
        .to raise_error(NotImplementedError, /must implement #process_sections/)
    end
  end

  describe '#schema_name' do
    it 'returns the demodulized class name without Schema suffix' do
      allow(test_schema_class).to receive(:name).and_return("TestModule::TestSchema")
      expect(schema.schema_name).to eq("Test")
    end
  end

  describe '#extract_link' do
    let(:doc) { Nokogiri::HTML("<div></div>") }

    it 'extracts link from anchor tag' do
      li = Nokogiri::HTML('<li><a href="https://example.com">Text</a></li>').at_css('li')
      expect(schema.send(:extract_link, li, "Some text")).to eq("https://example.com")
    end

    it 'extracts link from text content' do
      expect(schema.send(:extract_link, doc, "Text https://example.org more text"))
        .to eq("https://example.org")
    end

    it 'returns nil when no link is present' do
      expect(schema.send(:extract_link, doc, "Text without link")).to be_nil
    end
  end

  describe '#create_or_skip_section' do
    it 'creates a new section' do
      expect {
        section = schema.send(:create_or_skip_section, "New Section")
        expect(section).to be_persisted
        expect(section.name).to eq("New Section")
      }.to change(Section, :count).by(1)
      expect(stats[:sections_created]).to eq(1)
    end

    it 'skips existing section' do
      existing = create(:section, name: "Existing Section", socratic_seminar: socratic_seminar)
      expect {
        section = schema.send(:create_or_skip_section, "Existing Section")
        expect(section).to eq(existing)
      }.not_to change(Section, :count)
      expect(stats[:sections_skipped]).to eq(1)
    end

    it 'handles validation errors' do
      allow(Section).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Section.new))
      expect {
        section = schema.send(:create_or_skip_section, "Invalid Section")
        expect(section).to be_nil
      }.not_to change(Section, :count)
      expect(stats[:sections_failed]).to eq(1)
    end
  end

  describe '#create_or_skip_topic' do
    let(:section) { create(:section, socratic_seminar: socratic_seminar) }

    it 'creates a new topic' do
      expect {
        schema.send(:create_or_skip_topic, section, "New Topic", "https://example.com")
      }.to change(Topic, :count).by(1)
      expect(stats[:topics_created]).to eq(1)

      topic = Topic.last
      expect(topic.name).to eq("New Topic")
      expect(topic.link).to eq("https://example.com")
    end

    it 'skips existing topic' do
      existing = create(:topic, name: "Existing Topic", section: section)
      expect {
        schema.send(:create_or_skip_topic, section, "Existing Topic", nil)
      }.not_to change(Topic, :count)
      expect(stats[:topics_skipped]).to eq(1)
    end

    it 'handles validation errors' do
      allow_any_instance_of(Topic).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Topic.new))
      expect {
        schema.send(:create_or_skip_topic, section, "Invalid Topic", nil)
      }.not_to change(Topic, :count)
      expect(stats[:topics_failed]).to eq(1)
    end
  end

  describe '#log' do
    it 'adds message to output array and logs to Rails logger' do
      expect(Rails.logger).to receive(:info).with("[Import Topics] Test message")
      schema.send(:log, "Test message")
      expect(output).to include("Test message")
    end
  end
end
