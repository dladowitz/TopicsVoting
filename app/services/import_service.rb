require "open3"

class ImportService
  def self.import_sections_and_topics(seminar_number)
    new.import_sections_and_topics(seminar_number)
  end

  def import_sections_and_topics(seminar_number)
    command = "cd #{Rails.root} && bin/rails \"import:import_sections_and_topics[#{seminar_number}]\" 2>&1"
    output, status = Open3.capture2(command)
    [ status.success?, output ]
  end
end
