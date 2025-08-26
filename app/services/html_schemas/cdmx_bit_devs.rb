# Schema parser for cdmxbitdevs.org
require_relative "../html_schemas"
require_relative "base"

module HtmlSchemas
  class CDMXBitDevsSchema < BaseSchema
    def process_sections
      log "Using CDMXBitDevs schema parser"
      @doc.css("h3").each do |h3|
        # Extract section name from nested font tags
        section_name = extract_text_from_fonts(h3)
        next unless section_name.present?

        process_section(section_name, h3)
      end
      log "Import complete."
    end

    private

    def process_section(section_name, h3)
      section = create_or_skip_section(section_name)
      return unless section

      # Find the next sibling <ul> or <ol> (the list of topics)
      list = h3.xpath("following-sibling::*").find { |el| el.name == "ul" || el.name == "ol" }
      process_list_items(list, section) if list
    end

    def process_list_items(list, section, parent_topic = nil)
      list.css("> li").each do |li|
        # Check if there's a nested list
        nested_list = li.xpath("./ul | ./ol").first

        if nested_list
          # Create a copy of the li element and remove the nested list
          li_copy = li.dup
          li_copy.xpath("./ul | ./ol").remove
          direct_text = extract_text_from_fonts(li_copy)
        else
          # No nested list, extract text from the entire li element
          direct_text = extract_text_from_fonts(li)
        end

        next unless direct_text.present?

        # Extract link if present
        link = extract_link(li, direct_text)
        direct_text = direct_text.gsub(/(https?:\/\/\S+|www\.\S+)/, "").strip if link

        # Create topic for this <li> if it has content
        current_topic = create_or_skip_topic(section, direct_text, link, parent_topic)

        # Process any nested <ul> or <ol> within this <li>
        if nested_list && current_topic
          # Process nested items with the current topic as the parent
          process_list_items(nested_list, section, current_topic)
        elsif nested_list
          # If no current topic was created, process nested items with the same parent
          process_list_items(nested_list, section, parent_topic)
        end
      end
    end

    def extract_text_from_fonts(element)
      # Handle double-nested font tags
      text = element.css("font font").text.strip
      text = element.css("font").text.strip if text.blank?
      text = element.text.strip if text.blank?
      text
    end
  end
end
