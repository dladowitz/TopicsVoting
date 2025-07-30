require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  let(:socratic_seminar) { create(:socratic_seminar) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:valid_attributes) { { name: "Test Topic", section_id: section.id } }

  describe "GET #index" do
    it "returns a successful response" do
      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to be_successful
    end

    it "assigns all topics as @topics" do
      topic = create(:topic, socratic_seminar: socratic_seminar, section: section)
      get :index, params: { socratic_seminar_id: socratic_seminar.id }
      expect(assigns(:topics)).to include(topic)
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new, params: { socratic_seminar_id: socratic_seminar.id }
      expect(response).to be_successful
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
  end

  describe "POST #upvote" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section) }

    it "increases the vote count" do
      expect {
        post :upvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      }.to change { topic.reload.votes }.by(1)
    end
  end

  describe "POST #downvote" do
    let(:topic) { create(:topic, socratic_seminar: socratic_seminar, section: section, votes: 1) }

    it "decreases the vote count" do
      expect {
        post :downvote, params: { socratic_seminar_id: socratic_seminar.id, id: topic.id }
      }.to change { topic.reload.votes }.by(-1)
    end
  end
end 