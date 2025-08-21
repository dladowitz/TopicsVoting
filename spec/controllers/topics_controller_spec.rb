require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:valid_attributes) { { name: "Test Topic", section_id: section.id } }
  let(:invalid_attributes) { { name: "", section_id: nil } }

  describe "GET #index" do
    it "returns a successful response" do
      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "assigns topics ordered by votes and id" do
      topic1 = create(:topic, socratic_seminar: socratic_seminar, section: section, votes: 1)
      topic2 = create(:topic, socratic_seminar: socratic_seminar, section: section, votes: 2)
      topic3 = create(:topic, socratic_seminar: socratic_seminar, section: section, votes: 2)

      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:topics).to_a).to eq([ topic2, topic3, topic1 ])
    end

    it "assigns sections" do
      section1 = create(:section, socratic_seminar: socratic_seminar)
      section2 = create(:section, socratic_seminar: socratic_seminar)

      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:sections)).to include(section, section1, section2)
    end

    it "assigns vote states from session" do
      session[:votes] = { "1" => "up", "2" => "down" }
      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:vote_states)).to eq({ "1" => "up", "2" => "down" })
    end

    it "handles missing vote states" do
      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:vote_states)).to eq({})
    end
  end

  describe "GET #show" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    it "returns a successful response" do
      get :show, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      expect(response).to be_successful
    end

    it "assigns the requested topic" do
      get :show, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      expect(assigns(:topic)).to eq(topic)
    end

    it "handles non-existent topics" do
      expect {
        get :show, params: { socratic_seminar_id: socratic_seminar.id, id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "assigns a new topic" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:topic)).to be_a_new(Topic)
    end

    it "assigns available sections" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:sections)).to eq([ section ])
    end
  end

  describe "GET #edit" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    it "returns a successful response" do
      get :edit, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      expect(response).to be_successful
    end

    it "assigns the requested topic" do
      get :edit, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      expect(assigns(:topic)).to eq(topic)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Topic" do
        expect {
          post :create, params: {
            socratic_seminar_id: socratic_seminar.id,
            topic: valid_attributes
          }
        }.to change(Topic, :count).by(1)
      end

      it "redirects to the topics list" do
        post :create, params: {
          socratic_seminar_id: socratic_seminar.id,
          topic: valid_attributes
        }
        expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
      end
    end

    context "with invalid params" do
      it "does not create a new topic" do
        expect {
          post :create, params: {
            socratic_seminar_id: socratic_seminar.id,
            topic: invalid_attributes
          }
        }.not_to change(Topic, :count)
      end

      it "renders the new template" do
        post :create, params: {
          socratic_seminar_id: socratic_seminar.id,
          topic: invalid_attributes
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }
    let(:new_attributes) { { name: "Updated Topic" } }

    context "with valid params" do
      it "updates the requested topic" do
        patch :update, params: {
          socratic_seminar_id: socratic_seminar.id,
          id: topic.id,
          topic: new_attributes
        }
        topic.reload
        expect(topic.name).to eq("Updated Topic")
      end

      it "redirects to the topic" do
        patch :update, params: {
          socratic_seminar_id: socratic_seminar.id,
          id: topic.id,
          topic: new_attributes
        }
        expect(response).to redirect_to(socratic_seminar_topic_path(socratic_seminar, topic))
      end
    end

    context "with invalid params" do
      it "does not update the topic" do
        original_name = topic.name
        patch :update, params: {
          socratic_seminar_id: socratic_seminar.id,
          id: topic.id,
          topic: invalid_attributes
        }
        topic.reload
        expect(topic.name).to eq(original_name)
      end

      it "renders the edit template" do
        patch :update, params: {
          socratic_seminar_id: socratic_seminar.id,
          id: topic.id,
          topic: invalid_attributes
        }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    it "destroys the requested topic" do
      expect {
        delete :destroy, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      }.to change(Topic, :count).by(-1)
    end

    it "redirects to the topics list" do
      delete :destroy, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      expect(response).to redirect_to(socratic_seminar_topics_path(socratic_seminar))
    end
  end

  describe "POST #import_sections_and_topics" do
    let(:socratic_seminar) { create(:socratic_seminar) }

    context "when import succeeds" do
      before do
        allow(ImportService).to receive(:import_sections_and_topics)
          .with(socratic_seminar)
          .and_return([ true, "Import successful\nImported 5 sections" ])
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
        allow(ImportService).to receive(:import_sections_and_topics)
          .with(socratic_seminar)
          .and_return([ false, "Error occurred\nImport failed" ])
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

      it "calls import with correct seminar numbers" do
        allow(ImportService).to receive(:import_sections_and_topics).and_return([ true, "Success" ])

        post :import_sections_and_topics, params: { socratic_seminar_id: seminar_10.id }
        expect(ImportService).to have_received(:import_sections_and_topics).with(seminar_10)

        post :import_sections_and_topics, params: { socratic_seminar_id: seminar_99.id }
        expect(ImportService).to have_received(:import_sections_and_topics).with(seminar_99)
      end
    end

    context "with error output" do
      before do
        allow(ImportService).to receive(:import_sections_and_topics)
          .with(socratic_seminar)
          .and_return([ false, "Error: Invalid seminar number\nImport failed" ])
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

  describe "POST #upvote" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    context "with no previous vote" do
      it "increases the vote count" do
        expect {
          post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.to change { topic.reload.votes }.by(1)
      end

      it "sets the vote state in session" do
        post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        expect(session[:votes][topic.id.to_s]).to eq("up")
      end

      it "returns JSON response" do
        post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }, format: :json
        expect(response.content_type).to include('application/json')
        json = JSON.parse(response.body)
        expect(json["vote_count"]).to eq(1)
        expect(json["vote_state"]).to eq("up")
      end
    end

    context "with previous upvote" do
      before do
        session[:votes] = { topic.id.to_s => "up" }
        topic.update(votes: 1)
      end

      it "does not change the vote count" do
        expect {
          post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.not_to change { topic.reload.votes }
      end
    end

    context "with previous downvote" do
      before do
        session[:votes] = { topic.id.to_s => "down" }
        topic.update(votes: -1)
      end

      it "increases the vote count" do
        expect {
          post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.to change { topic.reload.votes }.by(1)
      end

      it "removes the vote state from session" do
        post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        expect(session[:votes][topic.id.to_s]).to be_nil
      end
    end
  end

  describe "POST #downvote" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    context "with no previous vote" do
      it "decreases the vote count" do
        expect {
          post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.to change { topic.reload.votes }.by(-1)
      end

      it "sets the vote state in session" do
        post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        expect(session[:votes][topic.id.to_s]).to eq("down")
      end

      it "returns JSON response" do
        post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }, format: :json
        expect(response.content_type).to include('application/json')
        json = JSON.parse(response.body)
        expect(json["vote_count"]).to eq(-1)
        expect(json["vote_state"]).to eq("down")
      end
    end

    context "with previous downvote" do
      before do
        session[:votes] = { topic.id.to_s => "down" }
        topic.update(votes: -1)
      end

      it "does not change the vote count" do
        expect {
          post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.not_to change { topic.reload.votes }
      end
    end

    context "with previous upvote" do
      before do
        session[:votes] = { topic.id.to_s => "up" }
        topic.update(votes: 1)
      end

      it "decreases the vote count" do
        expect {
          post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        }.to change { topic.reload.votes }.by(-1)
      end

      it "removes the vote state from session" do
        post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
        expect(session[:votes][topic.id.to_s]).to be_nil
      end
    end
  end

  describe "error handling" do
    it "raises RecordNotFound for non-existent socratic seminar" do
      expect {
        get :index, params: { socratic_seminar_id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for topic from different socratic seminar" do
      other_seminar = create(:socratic_seminar)
      other_section = create(:section, socratic_seminar: other_seminar)
      other_topic = create(:topic, socratic_seminar: other_seminar, section: other_section)

      expect {
        get :show, params: { socratic_seminar_id: socratic_seminar.id, id: other_topic.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
