require "rails_helper"

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

  describe "#process_sections" do
    it "raises NotImplementedError when called on base class" do
      expect { described_class.new(nil, nil, nil, nil).process_sections }
        .to raise_error(NotImplementedError, /must implement #process_sections/)
    end
  end

  describe "#schema_name" do
    it "returns the demodulized class name without Schema suffix" do
      allow(test_schema_class).to receive(:name).and_return("TestModule::TestSchema")
      expect(schema.schema_name).to eq("Test")
    end
  end

  describe "#extract_link" do
    let(:doc) { Nokogiri::HTML("<div></div>") }

    it "extracts link from anchor tag" do
      li = Nokogiri::HTML('<li><a href="https://example.com">Text</a></li>').at_css("li")
      expect(schema.send(:extract_link, li, "Some text")).to eq("https://example.com")
    end

    it "extracts link from text content" do
      expect(schema.send(:extract_link, doc, "Text https://example.org more text"))
        .to eq("https://example.org")
    end

    it "returns nil when no link is present" do
      expect(schema.send(:extract_link, doc, "Text without link")).to be_nil
    end

    it "returns nil when anchor tag has no href" do
      li = Nokogiri::HTML('<li><a>Text</a></li>').at_css("li")
      expect(schema.send(:extract_link, li, "Some text")).to be_nil
    end

    it "returns nil when anchor tag has empty href" do
      li = Nokogiri::HTML('<li><a href="">Text</a></li>').at_css("li")
      expect(schema.send(:extract_link, li, "Some text")).to be_nil
    end

    it "extracts www URLs from text content" do
      expect(schema.send(:extract_link, doc, "Text www.example.org more text"))
        .to eq("www.example.org")
    end

    it "extracts http URLs from text content" do
      expect(schema.send(:extract_link, doc, "Text http://example.org more text"))
        .to eq("http://example.org")
    end

    it "returns nil when anchor tag is not a direct child" do
      li = Nokogiri::HTML('<li><span><a href="https://example.com">Text</a></span></li>').at_css("li")
      expect(schema.send(:extract_link, li, "Some text")).to be_nil
    end
  end

  describe "#create_or_skip_section" do
    it "creates a new section" do
      expect {
        section = schema.send(:create_or_skip_section, "New Section")
        expect(section).to be_persisted
        expect(section.name).to eq("New Section")
      }.to change(Section, :count).by(1)
      expect(stats[:sections_created]).to eq(1)
    end

    it "sets the order field correctly" do
      # Create a section first to test order increment
      create(:section, socratic_seminar: socratic_seminar, order: 0)

      section = schema.send(:create_or_skip_section, "Second Section")
      expect(section.order).to eq(1)
      expect(output).to include("Created Section: Second Section (order: 1)")
    end

    it "sets order to 0 for the first section" do
      section = schema.send(:create_or_skip_section, "First Section")
      expect(section.order).to eq(0)
      expect(output).to include("Created Section: First Section (order: 0)")
    end

    it "skips existing section" do
      existing = create(:section, name: "Existing Section", socratic_seminar: socratic_seminar)
      expect {
        section = schema.send(:create_or_skip_section, "Existing Section")
        expect(section).to eq(existing)
      }.not_to change(Section, :count)
      expect(stats[:sections_skipped]).to eq(1)
    end

    it "handles validation errors" do
      allow(Section).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Section.new))
      expect {
        section = schema.send(:create_or_skip_section, "Invalid Section")
        expect(section).to be_nil
      }.not_to change(Section, :count)
      expect(stats[:sections_failed]).to eq(1)
    end
  end

  describe "#create_or_skip_topic" do
    let(:section) { create(:section, socratic_seminar: socratic_seminar) }

    it "creates a new topic" do
      expect {
        schema.send(:create_or_skip_topic, section, "New Topic", "https://example.com")
      }.to change(Topic, :count).by(1)
      expect(stats[:topics_created]).to eq(1)

      topic = Topic.last
      expect(topic.name).to eq("New Topic")
      expect(topic.link).to eq("https://example.com")
    end

    it "creates a new topic with parent" do
      parent_topic = create(:topic, section: section, name: "Parent Topic")
      expect {
        schema.send(:create_or_skip_topic, section, "Child Topic", "https://example.com", parent_topic)
      }.to change(Topic, :count).by(1)
      expect(stats[:topics_created]).to eq(1)

      topic = Topic.last
      expect(topic.name).to eq("Child Topic")
      expect(topic.parent_topic).to eq(parent_topic)
    end

    it "skips existing topic" do
      create(:topic, name: "Existing Topic", section: section)
      expect {
        schema.send(:create_or_skip_topic, section, "Existing Topic", nil)
      }.not_to change(Topic, :count)
      expect(stats[:topics_skipped]).to eq(1)
    end

    it "updates existing topic with parent relationship" do
      existing_topic = create(:topic, name: "Existing Topic", section: section, parent_topic: nil)
      parent_topic = create(:topic, section: section, name: "Parent Topic")

      expect {
        schema.send(:create_or_skip_topic, section, "Existing Topic", nil, parent_topic)
      }.not_to change(Topic, :count)

      existing_topic.reload
      expect(existing_topic.parent_topic).to eq(parent_topic)
      expect(stats[:topics_skipped]).to eq(1)
      expect(output.any? { |msg| msg.include?("Updated existing topic with parent: Existing Topic -> Parent Topic") }).to be true
    end

    it "does not update parent relationship if topic already has parent" do
      parent_topic = create(:topic, section: section, name: "Parent Topic")
      existing_topic = create(:topic, name: "Existing Topic", section: section, parent_topic: parent_topic)
      new_parent = create(:topic, section: section, name: "New Parent")

      expect {
        schema.send(:create_or_skip_topic, section, "Existing Topic", nil, new_parent)
      }.not_to change(Topic, :count)

      existing_topic.reload
      expect(existing_topic.parent_topic).to eq(parent_topic) # Should not change
      expect(stats[:topics_skipped]).to eq(1)
      expect(output).not_to include("Updated existing topic with parent")
    end

    it "handles validation errors" do
      allow_any_instance_of(Topic).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Topic.new))
      expect {
        schema.send(:create_or_skip_topic, section, "Invalid Topic", nil)
      }.not_to change(Topic, :count)
      expect(stats[:topics_failed]).to eq(1)
    end

    it "handles validation errors when creating topic with parent" do
      parent_topic = create(:topic, section: section, name: "Parent Topic")
      allow_any_instance_of(Topic).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Topic.new))

      expect {
        schema.send(:create_or_skip_topic, section, "Invalid Topic", nil, parent_topic)
      }.not_to change(Topic, :count)
      expect(stats[:topics_failed]).to eq(1)
    end

    it "logs topic creation with link" do
      expect {
        schema.send(:create_or_skip_topic, section, "Topic with Link", "https://example.com")
      }.to change(Topic, :count).by(1)

      expect(output.any? { |msg| msg.include?("Created Topic: Topic with Link") && msg.include?("link found") }).to be true
    end

    it "logs subtopic creation with parent" do
      parent_topic = create(:topic, section: section, name: "Parent Topic")

      expect {
        schema.send(:create_or_skip_topic, section, "Child Topic", nil, parent_topic)
      }.to change(Topic, :count).by(1)

      expect(output.any? { |msg| msg.include?("Created Subtopic: Child Topic") && msg.include?("subtopic of: Parent Topic") }).to be true
    end

    it "logs topic creation without link or parent" do
      expect {
        schema.send(:create_or_skip_topic, section, "Simple Topic", nil)
      }.to change(Topic, :count).by(1)

      expect(output.any? { |msg| msg.include?("Created Topic: Simple Topic") }).to be true
    end
  end

  describe "#log" do
    it "adds message to output array and logs to Rails logger" do
      expect(Rails.logger).to receive(:info).with("[Import Topics] Test message")
      schema.send(:log, "Test message")
      expect(output).to include("Test message")
    end
  end
end
