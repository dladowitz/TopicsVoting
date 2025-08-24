# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SocraticSeminarsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }

  describe 'GET #index' do
    it 'redirects to root path' do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it 'assigns the requested socratic_seminar as @socratic_seminar' do
      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end

    it 'assigns sections with topics as @sections' do
      get :show, params: { id: socratic_seminar.id }
      expect(assigns(:sections)).to eq(socratic_seminar.sections.includes(:topics))
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { organization_id: organization.id }
      expect(response).to be_successful
    end

    it 'assigns a new socratic_seminar as @socratic_seminar' do
      get :new, params: { organization_id: organization.id }
      expect(assigns(:socratic_seminar)).to be_a_new(SocraticSeminar)
    end

    it 'assigns the organization as @organization' do
      get :new, params: { organization_id: organization.id }
      expect(assigns(:organization)).to eq(organization)
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it 'assigns the requested socratic_seminar as @socratic_seminar' do
      get :edit, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) do
        {
          seminar_number: 1,
          date: Date.current,
          organization_id: organization.id
        }
      end

      it 'creates a new SocraticSeminar' do
        expect do
          post :create, params: { socratic_seminar: valid_attributes }
        end.to change(SocraticSeminar, :count).by(1)
      end

      it 'redirects to the organization' do
        post :create, params: { socratic_seminar: valid_attributes }
        expect(response).to redirect_to(organization)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) do
        {
          seminar_number: nil,
          organization_id: organization.id
        }
      end

      it 'does not create a new SocraticSeminar' do
        expect do
          post :create, params: { socratic_seminar: invalid_attributes }
        end.not_to change(SocraticSeminar, :count)
      end

      it 'renders new template' do
        post :create, params: { socratic_seminar: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          seminar_number: 2
        }
      end

      it 'updates the requested socratic_seminar' do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        socratic_seminar.reload
        expect(socratic_seminar.seminar_number).to eq(2)
      end

      it 'redirects to the socratic_seminar' do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: new_attributes }
        expect(response).to redirect_to(socratic_seminar)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) do
        {
          seminar_number: nil
        }
      end

      it 'renders edit template' do
        put :update, params: { id: socratic_seminar.id, socratic_seminar: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested socratic_seminar' do
      socratic_seminar_to_delete = socratic_seminar
      expect do
        delete :destroy, params: { id: socratic_seminar_to_delete.id }
      end.to change(SocraticSeminar, :count).by(-1)
    end

    it 'redirects to the root path' do
      delete :destroy, params: { id: socratic_seminar.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE #delete_sections' do
    let!(:section) { create(:section, socratic_seminar: socratic_seminar) }

    it 'destroys all sections for the socratic_seminar' do
      expect do
        delete :delete_sections, params: { id: socratic_seminar.id }
      end.to change(Section, :count).by(-1)
    end

    it 'redirects to the topics path' do
      delete :delete_sections, params: { id: socratic_seminar.id }
      expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
    end
  end

  describe 'GET #projector' do
    context 'when HOSTNAME environment variable is set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow(ENV).to receive(:[]).with('HOSTNAME').and_return('https://example.com')
      end

      it 'assigns the correct URL with HOSTNAME to @url' do
        get :projector, params: { id: socratic_seminar.id }
        expected_url = "https://example.com/socratic_seminars/#{socratic_seminar.id}/topics"
        expect(assigns(:url)).to eq(expected_url)
      end

      it 'renders the projector template' do
        get :projector, params: { id: socratic_seminar.id }
        expect(response).to render_template(:projector)
      end
    end

    context 'when HOSTNAME environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).and_return(nil) # This stubs out other ENV variables
        allow_any_instance_of(ActionDispatch::Request).to receive(:base_url).and_return('http://localhost:3000')
      end

      it 'assigns the correct URL with request base_url to @url' do
        get :projector, params: { id: socratic_seminar.id }
        expected_url = "http://localhost:3000/socratic_seminars/#{socratic_seminar.id}/topics"
        expect(assigns(:url)).to eq(expected_url)
      end

      it 'renders the projector template' do
        get :projector, params: { id: socratic_seminar.id }
        expect(response).to render_template(:projector)
      end
    end

    it 'returns a successful response' do
      get :projector, params: { id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it 'assigns the requested socratic_seminar as @socratic_seminar' do
      get :projector, params: { id: socratic_seminar.id }
      expect(assigns(:socratic_seminar)).to eq(socratic_seminar)
    end
  end
end
