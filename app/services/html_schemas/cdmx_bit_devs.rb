# Schema parser for cdmxbitdevs.org
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

    def process_list_items(list, section)
      list.css("> li").each do |li|
        # Extract topic text from nested font tags
        direct_text = extract_text_from_fonts(li)
        next unless direct_text.present?

        # Extract link if present
        link = extract_link(li, direct_text)
        direct_text = direct_text.gsub(/(https?:\/\/\S+|www\.\S+)/, "").strip if link

        create_or_skip_topic(section, direct_text, link)
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
