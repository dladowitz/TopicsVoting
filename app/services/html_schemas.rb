# Namespace for HTML schema parsers
module HtmlSchemas
  autoload :BaseSchema, File.expand_path("html_schemas/base", __dir__)
  autoload :SFBitcoinDevsSchema, File.expand_path("html_schemas/sf_bitcoin_devs", __dir__)
  autoload :CDMXBitDevsSchema, File.expand_path("html_schemas/cdmx_bit_devs", __dir__)
end
