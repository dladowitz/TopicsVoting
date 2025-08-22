# Load HTML schema classes
require_relative "../../app/services/html_schemas"

Dir[Rails.root.join("app", "services", "html_schemas", "*.rb")].sort.each do |file|
  require file
end
