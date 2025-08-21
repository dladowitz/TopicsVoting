# Schema parser for sfbitcoindevs.com
module HtmlSchemas
  class SFBitcoinDevsSchema < BaseSchema
    SECTIONS_TO_SKIP = [ "intro" ]

    def process_sections
      log "Using SFBitcoinDevs schema parser"
      @doc.css("h2").each do |h2|
        section_id = h2["id"]
        next unless section_id.present?

        # Convert dashes to spaces and capitalize first letter of each word, preserving case of "and"
        section_name = section_id.gsub("-", " ").split.map { |word| word.downcase == "and" ? "and" : word.capitalize }.join(" ")

        if SECTIONS_TO_SKIP.include?(section_name.split.first.downcase)
          log "Skipping. Section in Skip List: #{section_name}"
          next
        end

        process_section(section_name, h2)
      end
      log "Import complete."
    end

    private

    def process_section(section_name, h2)
      section = create_or_skip_section(section_name)
      return unless section

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
  end
end
