# Schema parser for sfbitcoindevs.com
require_relative "../html_schemas"
require_relative "base"

module HtmlSchemas
  class SFBitcoinDevsSchema < BaseSchema
    NON_VOTABLE_SECTIONS = [ "intro" ]
    NON_PAYABLE_SECTIONS = [ "intro" ]

    def process_sections
      log "Using SFBitcoinDevs schema parser"
      @doc.css("h2").each do |h2|
        section_id = h2["id"]
        next unless section_id.present?

        # Convert dashes to spaces and capitalize first letter of each word, preserving case of "and"
        section_name = section_id.gsub("-", " ").split.map { |word| word.downcase == "and" ? "and" : word.capitalize }.join(" ")

        process_section(section_name, h2)
      end
      log "Import complete."
    end

    private

    def non_votable_section?(section_name)
      NON_VOTABLE_SECTIONS.any? { |pattern| section_name.downcase.include?(pattern) }
    end

    def non_payable_section?(section_name)
      NON_PAYABLE_SECTIONS.any? { |pattern| section_name.downcase.include?(pattern) }
    end

    def process_section(section_name, h2)
      section = create_or_skip_section(section_name)
      return unless section

      # Find the next sibling <ul> or <ol> (the list of topics)
      list = h2.xpath("following-sibling::*").find { |el| el.name == "ul" || el.name == "ol" }
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
