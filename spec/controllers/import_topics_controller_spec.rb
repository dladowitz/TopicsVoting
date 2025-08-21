require 'rails_helper'

RSpec.describe ImportTopicsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:organization_role) { create(:organization_role, user: user, organization: organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }

  before do
    organization_role # Create the organization role
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #show" do
    context "when user can manage the seminar" do
      before do
        allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(true)
      end

      it "returns a successful response" do
        get :show, params: { socratic_seminar_id: socratic_seminar.id }
        expect(response).to be_successful
      end

      it "assigns the socratic seminar" do
        get :show, params: { socratic_seminar_id: socratic_seminar.id }
        expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
      end
    end

    context "when user cannot manage the seminar" do
      before do
        allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(false)
      end

      it "redirects to topics path" do
        get :show, params: { socratic_seminar_id: socratic_seminar.id }
        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
      end

      it "sets an alert message" do
        get :show, params: { socratic_seminar_id: socratic_seminar.id }
        expect(flash[:alert]).to match(/not authorized/)
      end
    end

    context "when seminar doesn't exist" do
      it "raises RecordNotFound" do
        expect {
          get :show, params: { socratic_seminar_id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    context "when user can manage the seminar" do
      before do
        allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(true)
      end

      context "when import succeeds" do
        before do
          allow(ImportService).to receive(:import_sections_and_topics)
            .with(socratic_seminar)
            .and_return([ true, "Import successful" ])
        end

        context "with HTML format" do
          it "redirects to import topics path" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }
            expect(response).to redirect_to(socratic_seminar_import_topics_path(socratic_seminar))
          end

          it "sets a success notice" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }
            expect(flash[:notice]).to eq("Import completed successfully")
          end
        end

        context "with Turbo Stream format" do
          it "renders turbo stream response" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }, format: :turbo_stream
            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq Mime[:turbo_stream]
          end

          it "updates the import results with success message" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }, format: :turbo_stream
            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include('turbo-stream action="update" target="import_results"')
            expect(assigns(:success)).to be true
            expect(assigns(:import_output)).to eq("Import successful")
          end
        end
      end

      context "when import fails" do
        before do
          allow(ImportService).to receive(:import_sections_and_topics)
            .with(socratic_seminar)
            .and_return([ false, "Import failed" ])
        end

        context "with HTML format" do
          it "redirects to import topics path" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }
            expect(response).to redirect_to(socratic_seminar_import_topics_path(socratic_seminar))
          end

          it "sets an alert message" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }
            expect(flash[:alert]).to eq("Import failed")
          end
        end

        context "with Turbo Stream format" do
          it "renders turbo stream response" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }, format: :turbo_stream
            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq Mime[:turbo_stream]
          end

          it "updates the import results with failure message" do
            post :create, params: { socratic_seminar_id: socratic_seminar.id }, format: :turbo_stream
            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include('turbo-stream action="update" target="import_results"')
            expect(assigns(:success)).to be false
            expect(assigns(:import_output)).to eq("Import failed")
          end
        end
      end
    end

    context "when user cannot manage the seminar" do
      before do
        allow(user).to receive(:can_manage?).with(socratic_seminar).and_return(false)
      end

      it "redirects to topics path" do
        post :create, params: { socratic_seminar_id: socratic_seminar.id }
        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
      end

      it "sets an alert message" do
        post :create, params: { socratic_seminar_id: socratic_seminar.id }
        expect(flash[:alert]).to match(/not authorized/)
      end

      it "does not call the import service" do
        expect(ImportService).not_to receive(:import_sections_and_topics)
        post :create, params: { socratic_seminar_id: socratic_seminar.id }
      end
    end
  end
end
