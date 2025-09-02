# Base class for HTML schema parsers
require_relative "../html_schemas"

module HtmlSchemas
  class BaseSchema
    attr_reader :doc, :seminar, :stats, :output

    def initialize(doc, seminar, stats, output)
      @doc = doc
      @seminar = seminar
      @stats = stats
      @output = output
    end

    def process_sections
      raise NotImplementedError, "#{self.class} must implement #process_sections"
    end

    def schema_name
      self.class.name.demodulize.gsub("Schema", "")
    end

    protected

    def log(message)
      @output << message
      Rails.logger.info("[Import Topics] #{message}")
    end

    def create_or_skip_topic(section, name, link, parent_topic = nil, votable: true, payable: true)
      topic = section.topics.find_by(name: name)
      if topic
        # Check if we need to update the parent relationship
        if parent_topic && topic.parent_topic_id.nil?
          topic.update!(parent_topic: parent_topic)
          log "  Updated existing topic with parent: #{topic.name} -> #{parent_topic.name}"
        end
        @stats[:topics_skipped] += 1
        log "Skipping Topic (already exists): #{topic.name}"
      else
        begin
          topic = section.topics.create!(
            name: name,
            link: link,
            parent_topic: parent_topic,
            votable: votable,
            payable: payable
          )
          @stats[:topics_created] += 1
          topic_type = parent_topic ? "Subtopic" : "Topic"
          log "  Created #{topic_type}: #{topic.name} #{'- link found' if topic.link.present?} #{'- subtopic of: ' + parent_topic.name if parent_topic}"
        rescue ActiveRecord::RecordInvalid => e
          @stats[:topics_failed] += 1
          log "  Failed to create Topic: #{name} (#{e.message})"
        end
      end
      topic
    end

    def create_or_skip_section(section_name)
      section = Section.find_by(name: section_name, socratic_seminar: @seminar)
      if section
        @stats[:sections_skipped] += 1
        log "Skipping Section (already exists): #{section.name}"
      else
        begin
          # Set order to the next available position
          next_order = @seminar.sections.count
          public_submissions_allowed = !non_publicly_submitable_section?(section_name)
          section = Section.create!(
            name: section_name,
            socratic_seminar: @seminar,
            order: next_order,
            allow_public_submissions: public_submissions_allowed
          )
          @stats[:sections_created] += 1
          log "Created Section: #{section.name} (order: #{next_order})"
        rescue ActiveRecord::RecordInvalid => e
          @stats[:sections_failed] += 1
          log "Failed to create Section: #{section_name} (#{e.message})"
          return nil # Skip processing topics for invalid sections
        end
      end
      section
    end

    def extract_link(li, direct_text)
      # First, look for <a> tags
      a_tag = li.css("> a").first
      return a_tag["href"] if a_tag && a_tag["href"].present?

      # Fall back to regex strategy
      match = direct_text.match(/(https?:\/\/[^\s]+|www\.[^\s]+)/)
      match[1] if match
    end

    def non_publicly_submitable_section?(section_name)
      false # By default, all sections allow public submissions
    end
  end
end
