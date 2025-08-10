# Service for importing sections and topics from bitcoinbuildersf.com
# @see lib/tasks/import_sections_and_topics.rake for the actual import logic
class ImportService
  # Class method wrapper for instance method
  # @param [String] seminar_number The seminar number to import
  # @return [Array<Boolean, String>] Success status and output message
  def self.import_sections_and_topics(seminar_number)
    new.import_sections_and_topics(seminar_number)
  end

  # Imports sections and topics for a specific seminar
  # @param [String] seminar_number The seminar number to import
  # @return [Array<Boolean, String>] Success status and output message
  # @note Executes a Rake task in a subprocess to perform the import
  def import_sections_and_topics(seminar_number)
    command = "cd #{Rails.root} && bin/rails \"import:import_sections_and_topics[#{seminar_number}]\" 2>&1"
    output, status = Open3.capture2(command)
    [ status.success?, output ]
  end
end
