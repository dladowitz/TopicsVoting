SECTIONS_TO_SKIP = [ "intro" ]

namespace :import do
  desc "Import Sections and Topics from bitcoinbuildersf.com for a given builder_number"
  task :import_sections_and_topics, [ :builder_number ] => :environment do |t, args|
    require "open-uri"
    require "nokogiri"

    builder_number = args[:builder_number].to_s
    builder_number_for_url = builder_number.rjust(2, "0")
    url = "https://www.bitcoinbuildersf.com/builder-#{builder_number_for_url}/"
    puts "Fetching: #{url}"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    seminar = SocraticSeminar.find_by(seminar_number: builder_number.to_i)
    if seminar.nil?
      puts "No SocraticSeminar found with seminar_number=#{builder_number}"
      exit 1
    end

    doc.css("h2").each do |h2|
      section_id = h2["id"]
      next unless section_id.present?
      # Humanize the section name
      section_name = section_id.gsub("-", " ").split.map(&:capitalize).join(" ")

      if SECTIONS_TO_SKIP.include?(section_name.split.first.downcase)
        puts "Skipping. Section in Skip List: #{section_name}"
        next
      end

      section = Section.find_by(name: section_name, socratic_seminar: seminar)
      if section
        puts "Skipping Section (already exists): #{section.name}"
      else
        section = Section.create!(name: section_name, socratic_seminar: seminar)
        puts "Created Section: #{section.name}"
      end

      # Find the next sibling <ul> or <ol> (the list of topics)
      list = h2.xpath("following-sibling::*").find { |el| el.name == "ul" || el.name == "ol" }
      next unless list

      # Process all <li> elements, including nested ones
      def process_list_items(list, section, seminar)
        list.css("> li").each do |li|
          # Create a copy of the li element and remove nested <ul> and <ol> elements
          li_copy = li.dup
          li_copy.css("ul, ol").remove

          # Get all visible text content of this <li> (including text from <a> tags, but excluding nested list content)
          direct_text = li_copy.text.strip

          # Extract link if present
          link = nil
          # First, look for <a> tags
          a_tag = li.css("> a").first
          if a_tag && a_tag["href"].present?
            link = a_tag["href"]
          else
            # Fall back to regex strategy
            direct_text = direct_text.gsub(/(https?:\/\/\S+|www\.\S+)/) do |match|
              link = match
              ""
            end.strip
          end

          # Create topic for this <li> if it has content
          if direct_text.present?
            topic = section.topics.find_by(name: direct_text, socratic_seminar: seminar)
            if topic
              puts "  Skipping Topic (already exists): #{topic.name}"
            else
              topic = section.topics.create!(name: direct_text, link: link, socratic_seminar: seminar)
              puts "  Created Topic: #{topic.name} #{'- link found' if topic.link.present?}"
            end
          end

          # Process any nested <ul> or <ol> within this <li>
          nested_list = li.xpath("./ul | ./ol").first
          if nested_list
            process_list_items(nested_list, section, seminar)
          end
        end
      end

      process_list_items(list, section, seminar)
    end
    puts "Import complete."
  end
end
