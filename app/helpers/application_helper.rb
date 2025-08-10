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
end
