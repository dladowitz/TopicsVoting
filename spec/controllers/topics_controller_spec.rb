require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  # ... [previous test code remains the same until the import_sections_and_topics section] ...

  describe "POST #import_sections_and_topics" do
    let(:socratic_seminar) { create(:socratic_seminar) }
    let(:expected_command) { "cd #{Rails.root} && bin/rails \"import:import_sections_and_topics[#{socratic_seminar.seminar_number}]\" 2>&1" }

    context "when import succeeds" do
      before do
        mock_kernel = double("Kernel")
        allow(mock_kernel).to receive(:`)
          .with(expected_command)
          .and_return("Import successful\nImported 5 sections")
        allow(mock_kernel).to receive(:eval)
          .with("$?.success?")
          .and_return(true)

        allow(controller).to receive(:kernel).and_return(mock_kernel)
      end

      it "redirects with success message" do
        post :import_sections_and_topics, params: { socratic_seminar_id: socratic_seminar.id }

        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
        expect(flash[:notice]).to match(/Import completed successfully/)
        expect(flash[:notice]).to include("Imported 5 sections")
      end
    end

    context "when import fails" do
      before do
        mock_kernel = double("Kernel")
        allow(mock_kernel).to receive(:`)
          .with(expected_command)
          .and_return("Error occurred\nImport failed")
        allow(mock_kernel).to receive(:eval)
          .with("$?.success?")
          .and_return(false)

        allow(controller).to receive(:kernel).and_return(mock_kernel)
      end

      it "redirects with error message" do
        post :import_sections_and_topics, params: { socratic_seminar_id: socratic_seminar.id }

        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
        expect(flash[:alert]).to match(/Import failed/)
      end
    end

    context "with different seminar numbers" do
      let(:seminar_10) { create(:socratic_seminar) }
      let(:seminar_99) { create(:socratic_seminar) }

      before do
        mock_kernel = double("Kernel")
        allow(mock_kernel).to receive(:`)
          .with(any_args)
          .and_return("Import successful")
        allow(mock_kernel).to receive(:eval)
          .with("$?.success?")
          .and_return(true)

        allow(controller).to receive(:kernel).and_return(mock_kernel)
      end

      it "uses the correct seminar number in the command" do
        post :import_sections_and_topics, params: { socratic_seminar_id: seminar_10.id }
        expect(controller.kernel).to have_received(:`).with(/import:import_sections_and_topics\[#{seminar_10.seminar_number}\]/)

        post :import_sections_and_topics, params: { socratic_seminar_id: seminar_99.id }
        expect(controller.kernel).to have_received(:`).with(/import:import_sections_and_topics\[#{seminar_99.seminar_number}\]/)
      end
    end

    context "with error output" do
      before do
        mock_kernel = double("Kernel")
        allow(mock_kernel).to receive(:`)
          .with(expected_command)
          .and_return("Error: Invalid seminar number\nImport failed")
        allow(mock_kernel).to receive(:eval)
          .with("$?.success?")
          .and_return(false)

        allow(controller).to receive(:kernel).and_return(mock_kernel)
      end

      it "includes the error message in the flash" do
        post :import_sections_and_topics, params: { socratic_seminar_id: socratic_seminar.id }
        expect(flash[:alert]).to include("Import failed")
      end
    end

    context "with non-existent seminar" do
      it "raises RecordNotFound" do
        expect {
          post :import_sections_and_topics, params: { socratic_seminar_id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  # ... [rest of the test code remains the same] ...
end
