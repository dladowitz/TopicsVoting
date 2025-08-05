require 'rails_helper'

RSpec.describe ImportService do
  describe '.import_sections_and_topics' do
    let(:seminar_number) { "42" }
    let(:expected_command) { "cd #{Rails.root} && bin/rails \"import:import_sections_and_topics[42]\" 2>&1" }
    let(:service) { described_class.new }

    context 'when command succeeds' do
      it 'returns success and output' do
        # Use Open3 to avoid messing with global state
        output = "Import successful\nImported 5 sections"
        status = double(success?: true)

        expect(Open3).to receive(:capture2)
          .with(expected_command)
          .and_return([ output, status ])

        success, actual_output = described_class.import_sections_and_topics(seminar_number)
        expect(success).to be true
        expect(actual_output).to include("Imported 5 sections")
      end
    end

    context 'when command fails' do
      it 'returns failure and error message' do
        output = "Error occurred\nImport failed"
        status = double(success?: false)

        expect(Open3).to receive(:capture2)
          .with(expected_command)
          .and_return([ output, status ])

        success, actual_output = described_class.import_sections_and_topics(seminar_number)
        expect(success).to be false
        expect(actual_output).to include("Import failed")
      end
    end
  end
end
