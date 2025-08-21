# Service for importing sections and topics from bitcoinbuildersf.com
class ImportService
  SECTIONS_TO_SKIP = [ "intro" ]

  # Class method wrapper for instance method
  # @param [SocraticSeminar] socratic_seminar The seminar to import topics for
  # @return [Array<Boolean, String>] Success status and output message
  def self.import_sections_and_topics(socratic_seminar)
    new.import_sections_and_topics(socratic_seminar)
  end

  # Imports sections and topics for a specific seminar
  # @param [SocraticSeminar] socratic_seminar The seminar to import topics for
  # @return [Array<Boolean, String>] Success status and output message
  def import_sections_and_topics(socratic_seminar)
    require "open-uri"
    require "nokogiri"

    @output = []
    @success = true
    @stats = {
      sections_created: 0,
      sections_skipped: 0,
      sections_failed: 0,
      topics_created: 0,
      topics_skipped: 0,
      topics_failed: 0
    }

    begin
      fetch_and_parse_html(socratic_seminar)
      process_sections
      log_final_stats if @success
      [ @success, @output.join("\n") ]
    rescue StandardError => e
      @success = false
      @output << "Error: #{e.message}"
      @output << e.backtrace.first(5).join("\n") if e.backtrace
      [ false, @output.join("\n") ]
    end
  end

  private

  def fetch_and_parse_html(socratic_seminar)
    @seminar = socratic_seminar
    log "Fetching: #{@seminar.topics_list_url}"
    response = Net::HTTP.get_response(URI(@seminar.topics_list_url))
    unless response.is_a?(Net::HTTPSuccess)
      raise OpenURI::HTTPError.new("#{response.code} Not Found", StringIO.new)
    end
    html = response.body
    @doc = Nokogiri::HTML(html)
  end

  def process_sections
    @doc.css("h2").each do |h2|
      section_id = h2["id"]
      next unless section_id.present?

      # Humanize the section name
      section_name = section_id.gsub("-", " ").split.map(&:capitalize).join(" ")

      if SECTIONS_TO_SKIP.include?(section_name.split.first.downcase)
        log "Skipping. Section in Skip List: #{section_name}"
        next
      end

      process_section(section_name, h2)
    end
    log "Import complete."
  end

  def process_section(section_name, h2)
    section = Section.find_by(name: section_name, socratic_seminar: @seminar)
    if section
      @stats[:sections_skipped] += 1
      log "Skipping Section (already exists): #{section.name}"
    else
      begin
        section = Section.create!(name: section_name, socratic_seminar: @seminar)
        @stats[:sections_created] += 1
        log "Created Section: #{section.name}"
      rescue ActiveRecord::RecordInvalid => e
        @stats[:sections_failed] += 1
        log "Failed to create Section: #{section_name} (#{e.message})"
        return nil # Skip processing topics for invalid sections
      end
    end

    # Find the next sibling <ul> or <ol> (the list of topics)
    list = h2.xpath("following-sibling::*").find { |el| el.name == "ul" || el.name == "ol" }
    process_list_items(list, section) if list
  end

  def process_list_items(list, section, parent_topic = nil)
    list.css("> li").each do |li|
      # Create a copy of the li element and remove nested <ul> and <ol> elements
      li_copy = li.dup
      li_copy.css("ul, ol").remove

      # Get all visible text content of this <li> (including text from <a> tags, but excluding nested list content)
      direct_text = li_copy.text.strip

      # Extract link if present
      link = extract_link(li, direct_text)
      direct_text = direct_text.gsub(/(https?:\/\/\S+|www\.\S+)/, "").strip if link

      # Create topic for this <li> if it has content
      if direct_text.present?
        create_or_skip_topic(section, direct_text, link)
      end

      # Process any nested <ul> or <ol> within this <li>
      nested_list = li.xpath("./ul | ./ol").first
      process_list_items(nested_list, section) if nested_list
    end
  end

  def extract_link(li, direct_text)
    # First, look for <a> tags
    a_tag = li.css("> a").first
    return a_tag["href"] if a_tag && a_tag["href"].present?

    # Fall back to regex strategy
    match = direct_text.match(/(https?:\/\/[^\s]+|www\.[^\s]+)/)
    match[1] if match
  end

  def create_or_skip_topic(section, name, link)
    topic = section.topics.find_by(name: name)
    if topic
      @stats[:topics_skipped] += 1
      log "  Skipping Topic (already exists): #{topic.name}"
    else
      begin
        topic = section.topics.create!(name: name, link: link)
        @stats[:topics_created] += 1
        log "  Created Topic: #{topic.name} #{'- link found' if topic.link.present?}"
      rescue ActiveRecord::RecordInvalid => e
        @stats[:topics_failed] += 1
        log "  Failed to create Topic: #{name} (#{e.message})"
      end
    end
  end

  def log(message)
    # Add to output array for display in the view
    @output << message
    # Log to Rails logger for infrastructure monitoring
    Rails.logger.info("[Import Topics] #{message}")
  end

  def log_final_stats
    log "\nImport Statistics:"
    log "----------------"
    log "Created:"
    log "  Sections: #{@stats[:sections_created]}"
    log "  Topics:   #{@stats[:topics_created]}"
    log " "
    log "Skipped:"
    log "  Sections: #{@stats[:sections_skipped]}"
    log "  Topics:   #{@stats[:topics_skipped]}"
    log " "
    log "Failed:"
    log "  Sections: #{@stats[:sections_failed]}"
    log "  Topics:   #{@stats[:topics_failed]}"
    log "----------------"
  end
end
