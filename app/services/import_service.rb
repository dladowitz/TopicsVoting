# Service for importing sections and topics from bitcoinbuildersf.com
# @see lib/tasks/import_sections_and_topics.rake for the actual import logic
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
  # @note Executes a Rake task in a subprocess to perform the import
  def import_sections_and_topics(socratic_seminar)
    command = "cd #{Rails.root} && bin/rails \"import:import_sections_and_topics[#{socratic_seminar.id}]\" 2>&1"
    output, status = Open3.capture2(command)
    [ status.success?, output ]
  end
end
