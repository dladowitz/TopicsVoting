module ApplicationHelper
  def sanitize_url(url)
    return nil if url.blank?
    uri = URI.parse(url)
    return url if uri.scheme.in?(%w[http https])
    nil
  rescue URI::InvalidURIError
    nil
  end
end
