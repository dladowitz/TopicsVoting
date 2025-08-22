# Load HTML schema classes
Rails.autoloaders.main.push_dir(Rails.root.join("app", "services"))
require_relative "../../app/services/html_schemas"
