# Service for importing sections and topics from various HTML schemas
require_relative "html_schemas/base_schema"
require_relative "html_schemas/sf_bitcoin_devs_schema"
require_relative "html_schemas/cdmx_bit_devs_schema"

class ImportService
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
    schema = detect_schema
    schema.process_sections
  end

  def detect_schema
    # Try to detect schema based on URL and HTML structure
    if @seminar.topics_list_url.include?("sfbitcoindevs.com")
      SFBitcoinDevsSchema.new(@doc, @seminar, @stats, @output)
    elsif @seminar.topics_list_url.include?("cdmxbitdevs.org")
      CDMXBitDevsSchema.new(@doc, @seminar, @stats, @output)
    else
      # Try to auto-detect based on HTML structure
      if @doc.css("h2[id]").any?
        log "Auto-detected SFBitcoinDevs schema"
        SFBitcoinDevsSchema.new(@doc, @seminar, @stats, @output)
      elsif @doc.css("h3 font font").any?
        log "Auto-detected CDMXBitDevs schema"
        CDMXBitDevsSchema.new(@doc, @seminar, @stats, @output)
      else
        # If we can't detect a specific schema, fall back to SFBitcoinDevs schema
        log "Unable to detect specific schema, falling back to SFBitcoinDevs schema"
        SFBitcoinDevsSchema.new(@doc, @seminar, @stats, @output)
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
