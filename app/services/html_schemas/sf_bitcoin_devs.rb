# Schema parser for sfbitcoindevs.com
require_relative "../html_schemas"
require_relative "base"

module HtmlSchemas
  class SFBitcoinDevsSchema < BaseSchema
    SECTIONS_TO_SKIP = [ "vote on topics" ]
    NON_VOTABLE_SECTIONS = [ "intro", "live videcoding request", "vibe coded app showcase", "startup showcase" ]
    NON_PAYABLE_SECTIONS = [ "intro" ]

    def process_sections
      log "Using SFBitcoinDevs schema parser"
      @doc.css("h2").each do |h2|
        section_id = h2["id"]
        next unless section_id.present?

        # Convert dashes to spaces and capitalize first letter of each word, preserving case of "and"
        section_name = section_id.gsub("-", " ").split.map { |word| word.downcase == "and" ? "and" : word.capitalize }.join(" ")

        # Skip sections that match any pattern in SECTIONS_TO_SKIP
        if SECTIONS_TO_SKIP.any? { |pattern| normalize_section_name(section_name) == pattern.downcase }
          log "Skipping section: #{section_name}"
          next
        end

        process_section(section_name, h2)
      end
      log "Import complete."
    end

    private

    def normalize_section_name(name)
      # Remove duration in parentheses and any extra whitespace
      name.gsub(/\s*\(\d+\s*(?:min|minute)s?\)\s*$/i, "").strip.downcase
    end

    def non_votable_section?(section_name)
      normalized_name = normalize_section_name(section_name)
      NON_VOTABLE_SECTIONS.any? { |pattern| normalized_name.include?(pattern.downcase) }
    end

    def non_payable_section?(section_name)
      normalized_name = normalize_section_name(section_name)
      NON_PAYABLE_SECTIONS.any? { |pattern| normalized_name.include?(pattern.downcase) }
    end

    def process_section(section_name, h2)
      section = create_or_skip_section(section_name)
      return unless section

      # Find all siblings until the next h2
      siblings = h2.xpath("following-sibling::*")
      # Find the first list before the next h2
      list = nil
      siblings.each do |el|
        break if el.name == "h2"
        if el.name == "ul" || el.name == "ol"
          list = el
          break
        end
      end
      process_list_items(list, section) if list
    end

    def process_list_items(list, section, parent_topic = nil)
      is_non_votable = non_votable_section?(section.name)
      is_non_payable = non_payable_section?(section.name)
      list.css("> li").each do |li|
        # Get the text content before any nested lists
        # First, find if there's a nested list
        nested_list = li.xpath("./ul | ./ol").first

        if nested_list
          # Get text content before the nested list
          # Create a copy of the li element and remove the nested list
          li_copy = li.dup
          li_copy.xpath("./ul | ./ol").remove
          direct_text = li_copy.text.strip
        else
          # No nested list, get all text
          direct_text = li.text.strip
        end

        # Extract link if present
        link = extract_link(li, direct_text)
        direct_text = direct_text.gsub(/(https?:\/\/\S+|www\.\S+)/, "").strip if link

        # Create topic for this <li> if it has content
        current_topic = nil
        if direct_text.present?
          current_topic = create_or_skip_topic(section, direct_text, link, parent_topic, votable: !is_non_votable, payable: !is_non_payable)
        end

        # Process any nested <ul> or <ol> within this <li>
        if nested_list
          if current_topic
            # Process nested items with the current topic as the parent
            process_list_items(nested_list, section, current_topic)
          else
            # If no current topic was created, process nested items with the same parent
            process_list_items(nested_list, section, parent_topic)
          end
        end
      end
    end
  end
end
