# frozen_string_literal: true

require "rails_helper"

RSpec.describe SectionsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let!(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:valid_attributes) { { name: "Test Section" } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "renders the laptop template" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to render_template("sections/laptop/new")
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { socratic_seminar_id: socratic_seminar.id, id: section.id }
      expect(response).to be_successful
    end

    it "renders the laptop template" do
      get :edit, params: { socratic_seminar_id: socratic_seminar.id, id: section.id }
      expect(response).to render_template("sections/laptop/edit")
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Section" do
        expect {
          post :create, params: { socratic_seminar_id: socratic_seminar.id, section: valid_attributes }
        }.to change(Section, :count).by(1)
      end

      it "sets default order when order is not provided" do
        expect {
          post :create, params: { socratic_seminar_id: socratic_seminar.id, section: valid_attributes }
        }.to change(Section, :count).by(1)

        new_section = Section.last
        expect(new_section.order).to eq(0) # Default value from migration
      end

      it "redirects to the socratic seminar edit page" do
        post :create, params: { socratic_seminar_id: socratic_seminar.id, section: valid_attributes }
        expect(response).to redirect_to(edit_socratic_seminar_path(socratic_seminar))
      end

      it "uses provided order when order is specified" do
        attributes_with_order = valid_attributes.merge(order: 5)
        post :create, params: { socratic_seminar_id: socratic_seminar.id, section: attributes_with_order }

        new_section = Section.last
        expect(new_section.order).to eq(5)
      end

      it "sets default order when order is explicitly nil" do
        # Create a section with order explicitly set to nil to test the default logic
        attributes_with_nil_order = valid_attributes.merge(order: nil)
        post :create, params: { socratic_seminar_id: socratic_seminar.id, section: attributes_with_nil_order }

        new_section = Section.last
        expect(new_section.order).to eq(1) # Should be 1 since there's already one section
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { socratic_seminar_id: socratic_seminar.id, section: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders the new template" do
        post :create, params: { socratic_seminar_id: socratic_seminar.id, section: invalid_attributes }
        expect(response).to render_template("sections/laptop/new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Section" } }

      it "updates the requested section" do
        put :update, params: { socratic_seminar_id: socratic_seminar.id, id: section.id, section: new_attributes }
        section.reload
        expect(section.name).to eq("Updated Section")
      end

      it "redirects to the socratic seminar edit page" do
        put :update, params: { socratic_seminar_id: socratic_seminar.id, id: section.id, section: new_attributes }
        expect(response).to redirect_to(edit_socratic_seminar_path(socratic_seminar))
      end

      it "updates the order when order is provided" do
        attributes_with_order = new_attributes.merge(order: 10)
        put :update, params: { socratic_seminar_id: socratic_seminar.id, id: section.id, section: attributes_with_order }
        section.reload
        expect(section.order).to eq(10)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { socratic_seminar_id: socratic_seminar.id, id: section.id, section: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders the edit template" do
        put :update, params: { socratic_seminar_id: socratic_seminar.id, id: section.id, section: invalid_attributes }
        expect(response).to render_template("sections/laptop/edit")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:section_with_topics) { create(:section, socratic_seminar: socratic_seminar) }
    let!(:topics) { create_list(:topic, 2, section: section_with_topics) }

    it "destroys the requested section" do
      expect {
        delete :destroy, params: { socratic_seminar_id: socratic_seminar.id, id: section.id }
      }.to change(Section, :count).by(-1)
    end

    it "destroys associated topics" do
      expect {
        delete :destroy, params: { socratic_seminar_id: socratic_seminar.id, id: section_with_topics.id }
      }.to change(Topic, :count).by(-2)
    end

    it "redirects to the socratic seminar edit page" do
      delete :destroy, params: { socratic_seminar_id: socratic_seminar.id, id: section.id }
      expect(response).to redirect_to(edit_socratic_seminar_path(socratic_seminar))
    end
  end
end
