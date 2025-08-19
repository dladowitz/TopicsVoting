# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SocraticSeminarsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:valid_attributes) { attributes_for(:socratic_seminar, organization_id: organization.id) }
  let(:invalid_attributes) { { seminar_number: nil, date: nil, organization_id: nil } }

  describe "GET #index" do
    it "redirects to root path" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #show" do
    let(:socratic_seminar) { create(:socratic_seminar) }

    it "returns a successful response" do
      get :show, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "assigns the requested socratic_seminar as @socratic_seminar" do
      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end

    it "assigns sections with topics as @sections" do
      section = create(:section, socratic_seminar: socratic_seminar)
      topic = create(:topic, section: section)

      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:sections)).to include(section)
      expect(assigns(:sections).first.topics).to include(topic)
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    let(:socratic_seminar) { create(:socratic_seminar) }

    it "returns a successful response" do
      get :edit, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new SocraticSeminar" do
        expect {
          post :create, params: { socratic_seminar: valid_attributes }
        }.to change(SocraticSeminar, :count).by(1)
      end

      it "redirects to the created socratic_seminar" do
        post :create, params: { socratic_seminar: valid_attributes }
        expect(response).to redirect_to(SocraticSeminar.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { socratic_seminar: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    let(:socratic_seminar) { create(:socratic_seminar) }
    let(:new_attributes) { { seminar_number: 42 } }

    context "with valid params" do
      it "updates the requested socratic_seminar" do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        socratic_seminar.reload
        expect(socratic_seminar.seminar_number).to eq(42)
      end

      it "redirects to the socratic_seminar" do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        expect(response).to redirect_to(socratic_seminar)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:socratic_seminar) { create(:socratic_seminar) }

    it "destroys the requested socratic_seminar" do
      expect {
        delete :destroy, params: { id: socratic_seminar.id }
      }.to change(SocraticSeminar, :count).by(-1)
    end

    it "redirects to the root path" do
      delete :destroy, params: { id: socratic_seminar.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #delete_sections" do
    let(:socratic_seminar) { create(:socratic_seminar) }
    let!(:section) { create(:section, socratic_seminar: socratic_seminar) }
    let!(:topic) { create(:topic, section: section) }

    it "deletes all sections and their associated records" do
      expect {
        delete :delete_sections, params: { id: socratic_seminar.id }
      }.to change(Section, :count).by(-1)
        .and change(Topic, :count).by(-1)
    end

    it "redirects to the seminar's topics page" do
      delete :delete_sections, params: { id: socratic_seminar.id }
      expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
    end
  end
end
