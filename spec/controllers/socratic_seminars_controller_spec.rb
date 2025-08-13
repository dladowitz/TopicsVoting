require 'rails_helper'

RSpec.describe SocraticSeminarsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all socratic_seminars as @socratic_seminars in descending date order" do
      seminar1 = create(:socratic_seminar, date: 1.day.ago, organization: organization)
      seminar2 = create(:socratic_seminar, date: Time.current, organization: organization)
      get :index
      expect(assigns(:socratic_seminars)).to eq([ seminar2, seminar1 ])
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "initializes a new socratic seminar" do
      get :new
      expect(assigns(:socratic_seminar)).to be_a_new(SocraticSeminar)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) {
        { seminar_number: 1, date: 1.month.from_now, builder_sf_link: "https://www.bitcoinbuildersf.com/builder-01/", organization_id: organization.id }
      }

      it "creates a new SocraticSeminar" do
        expect {
          post :create, params: { socratic_seminar: valid_attributes }
        }.to change(SocraticSeminar, :count).by(1)
      end

      it "redirects to the created socratic_seminar" do
        post :create, params: { socratic_seminar: valid_attributes }
        expect(response).to redirect_to(socratic_seminar_path(SocraticSeminar.last))
      end

      it "creates and returns JSON when requested" do
        post :create, params: { socratic_seminar: valid_attributes }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { seminar_number: nil, date: nil } }

      it "does not create a new socratic seminar" do
        expect {
          post :create, params: { socratic_seminar: invalid_attributes }
        }.not_to change(SocraticSeminar, :count)
      end

      it "renders the new template" do
        post :create, params: { socratic_seminar: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
      end

      it "returns errors as JSON when requested" do
        post :create, params: { socratic_seminar: invalid_attributes }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    # Don't think we need this
    # it "returns JSON when requested" do
    #   get :show, params: { id: socratic_seminar.id }, format: :json
    #   expect(response.content_type).to include('application/json')
    #   expect(response).to be_successful
    # end

    it "handles non-existent seminars" do
      expect {
        get :show, params: { id: 'nonexistent' }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "assigns the requested socratic_seminar" do
      get :edit, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_attributes) { { date: socratic_seminar.date, seminar_number: 4 } }

      it "updates the requested socratic_seminar" do
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        socratic_seminar.reload
        expect(socratic_seminar.seminar_number).to eq(4)
      end

      it "redirects to the socratic_seminar" do
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        expect(response).to redirect_to(socratic_seminar_path(socratic_seminar))
      end

      it "updates and returns JSON when requested" do
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { seminar_number: nil, date: nil } }

      it "does not update the socratic seminar" do
        original_number = socratic_seminar.seminar_number
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
        socratic_seminar.reload
        expect(socratic_seminar.seminar_number).to eq(original_number)
      end

      it "renders the edit template" do
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
      end

      it "returns errors as JSON when requested" do
        patch :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:socratic_seminar_to_delete) { create(:socratic_seminar) }
    let!(:section) { create(:section, socratic_seminar: socratic_seminar_to_delete) }
    let!(:topic) { create(:topic, section: section, socratic_seminar: socratic_seminar_to_delete) }
    let!(:payment) { create(:payment, topic: topic) }

    it "destroys the requested socratic_seminar and all its associations" do
      expect {
        delete :destroy, params: { id: socratic_seminar_to_delete.id }
      }.to change(SocraticSeminar, :count).by(-1)

      # Verify all associations are destroyed
      expect(Section.where(id: section.id)).not_to exist
      expect(Topic.where(id: topic.id)).not_to exist
      expect(Payment.where(id: payment.id)).not_to exist
    end

    it "redirects to the socratic_seminars list" do
      delete :destroy, params: { id: socratic_seminar_to_delete.id }
      expect(response).to redirect_to(socratic_seminars_url)
      expect(response).to have_http_status(:see_other)
    end

    it "returns no content when requested via JSON" do
      delete :destroy, params: { id: socratic_seminar_to_delete.id }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST #disable_admin_mode_action" do
    before do
      cookies[:admin_mode] = 'true'
    end

    it "disables admin mode" do
      post :disable_admin_mode_action
      expect(cookies[:admin_mode]).to be_nil
      expect(assigns(:admin_mode)).to be false
    end

    it "redirects to socratic seminars index" do
      post :disable_admin_mode_action
      expect(response).to redirect_to(socratic_seminars_path)
      expect(flash[:notice]).to eq("Admin mode has been disabled.")
    end
  end

  describe "DELETE #delete_sections" do
    let!(:seminar) { create(:socratic_seminar) }
    let!(:section1) { create(:section, socratic_seminar: seminar) }
    let!(:section2) { create(:section, socratic_seminar: seminar) }
    let!(:topic1) { create(:topic, section: section1, socratic_seminar: seminar) }
    let!(:topic2) { create(:topic, section: section2, socratic_seminar: seminar) }
    let!(:payment1) { create(:payment, topic: topic1) }
    let!(:payment2) { create(:payment, topic: topic2) }

    it "deletes all sections and their associated records" do
      delete :delete_sections, params: { id: seminar.id }

      # Verify all associated records are deleted
      expect(Section.where(socratic_seminar_id: seminar.id)).not_to exist
      expect(Topic.where(section_id: [ section1.id, section2.id ])).not_to exist
      expect(Payment.where(topic_id: [ topic1.id, topic2.id ])).not_to exist

      # Verify the seminar itself still exists
      expect(SocraticSeminar.find(seminar.id)).to eq(seminar)
    end

    it "redirects to the seminar's topics page" do
      delete :delete_sections, params: { id: seminar.id }
      expect(response).to redirect_to(socratic_seminar_topics_path(seminar))
      expect(flash[:notice]).to eq("All sections, topics, and payments for this seminar have been deleted.")
    end
  end
end
