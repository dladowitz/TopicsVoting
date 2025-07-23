namespace :import do
  desc "Import Sections and Topics from bitcoinbuildersf.com for a given builder_number"
  task :import_sections_and_topics, [:builder_number] => :environment do |t, args|
    require 'open-uri'
    require 'nokogiri'

    builder_number = args[:builder_number].to_s
    builder_number_for_url = builder_number.rjust(2, '0')
    url = "https://www.bitcoinbuildersf.com/builder-#{builder_number_for_url}/"
    puts "Fetching: #{url}"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    seminar = SocraticSeminar.find_by(seminar_number: builder_number.to_i)
    if seminar.nil?
      puts "No SocraticSeminar found with seminar_number=#{builder_number}"
      exit 1
    end

    doc.css('h2').each do |h2|
      section_id = h2['id']
      next unless section_id.present?
      # Humanize the section name
      section_name = section_id.gsub('-', ' ').split.map(&:capitalize).join(' ')
      section = Section.create!(name: section_name, socratic_seminar: seminar)
      puts "Created Section: #{section.name}"

      # Find the next sibling <ul> or <ol> (the list of topics)
      list = h2.xpath('following-sibling::*').find { |el| el.name == 'ul' || el.name == 'ol' }
      next unless list
      list.css('li').each do |li|
        text = li.text.strip
        # Extract link if present
        link = nil
        text = text.gsub(/(https?:\/\/\S+|www\.\S+)/) do |match|
          link = match
          ''
        end.strip
        topic = section.topics.create!(name: text, link: link, socratic_seminar: seminar)
        puts "  Created Topic: #{topic.name}#{" (link: #{topic.link})" if topic.link.present?}"
      end
    end
    puts "Import complete."
  end
end 