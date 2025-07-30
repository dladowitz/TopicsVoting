require 'rails_helper'

RSpec.describe SocraticSeminarsController, type: :controller do
  let(:socratic_seminar) { create(:socratic_seminar) }
  # let(:valid_attributes) { { date: socratic_seminar.date, seminar_number: 3 } }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all socratic_seminars as @socratic_seminars" do
      seminar1 = create(:socratic_seminar)
      seminar2 = create(:socratic_seminar)
      get :index
      expect(assigns(:socratic_seminars)).to match_array([seminar1, seminar2])
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { 
        { seminar_number: 1, date: 1.month.from_now, builder_sf_link: "https://www.bitcoinbuildersf.com/builder-0#{1}/" } 
      }

      it "creates a new SocraticSeminar" do
        expect {
          post :create, params: { socratic_seminar: valid_attributes }
        }.to change(SocraticSeminar, :count).by(2)
      end

      it "redirects to the created socratic_seminar" do
        post :create, params: { socratic_seminar: valid_attributes }
        expect(response).to redirect_to(socratic_seminar_path(SocraticSeminar.last))
      end
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: socratic_seminar.id }
      expect(response).to be_successful
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
    end
  end

  describe "DELETE #destroy" do
    let!(:socratic_seminar_to_delete) { create(:socratic_seminar) }
    let!(:section) { create(:section, socratic_seminar: socratic_seminar_to_delete) }
    let!(:topic) { create(:topic, section: section, socratic_seminar: socratic_seminar_to_delete) }

    it "destroys the requested socratic_seminar and its associations" do
      expect {
        delete :destroy, params: { id: socratic_seminar_to_delete.id }
      }.to change(SocraticSeminar, :count).by(-1)
      
      # Verify associations are destroyed
      expect(Section.where(id: section.id)).not_to exist
      expect(Topic.where(id: topic.id)).not_to exist
    end

    it "redirects to the socratic_seminars list" do
      delete :destroy, params: { id: socratic_seminar_to_delete.id }
      expect(response).to redirect_to(socratic_seminars_url)
    end
  end
end