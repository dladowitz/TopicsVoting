require 'open-uri'
require 'nokogiri'

namespace :import do
  desc "Import Bitcoin Products topics from bitcoinbuildersf.com/builder-01 into the Topic model"
  task bitcoin_products: :environment do
    url = 'https://www.bitcoinbuildersf.com/builder-01/'
    puts "Fetching topics from #{url}..."
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    # Find the H2 with the id 'bitcoin-products-20-min'
    h2 = doc.at_css('h2#bitcoin-products-20-min')
    if h2.nil?
      puts "Could not find the section with id 'bitcoin-products-20-min'"
      exit 1
    end

    # Get the next sibling <ul> or <ol> (the list of topics)
    list = h2.xpath('following-sibling::*').find { |el| el.name == 'ul' || el.name == 'ol' }
    if list.nil?
      puts "Could not find a list (<ul> or <ol>) after the H2 section."
      exit 1
    end

    topics = list.css('li').map { |li| li.text.strip }
    puts "Found #{topics.size} topics. Importing..."

    imported = 0
    topics.each do |topic_name|
      unless Topic.exists?(name: topic_name)
        Topic.create!(name: topic_name, votes: 0, sats_received: 0)
        puts "Imported: #{topic_name}"
        imported += 1
      else
        puts "Already exists: #{topic_name}"
      end
    end
    puts "Imported #{imported} new topics."
  end
end 