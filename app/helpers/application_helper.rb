# Global helper methods available to all views
module ApplicationHelper
  # Sanitizes a URL to ensure it uses HTTP(S)
  # @param [String] url The URL to sanitize
  # @return [String, nil] The sanitized URL if valid, nil otherwise
  # @example
  #   sanitize_url("https://example.com") # => "https://example.com"
  #   sanitize_url("javascript:alert(1)") # => nil
  def sanitize_url(url)
    return nil if url.blank?
    uri = URI.parse(url)
    return url if uri.scheme.in?(%w[http https])
    nil
  rescue URI::InvalidURIError
    nil
  end

  # Formats a number with commas for better readability
  # @param [Integer, String] number The number to format
  # @return [String] The formatted number with commas
  # @example
  #   format_with_commas(11145) # => "11,145"
  #   format_with_commas("11145") # => "11,145"
  def format_with_commas(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
