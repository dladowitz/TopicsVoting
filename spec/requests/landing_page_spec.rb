# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "LandingPage", type: :request do
  before do
    allow_any_instance_of(LandingPageController).to receive(:current_layout).and_return('laptop')
  end

  describe "GET /" do
    let(:organization) { create(:organization) }

    context "with many events" do
      before do
        # Create 15 upcoming seminars
        15.times do |i|
          create(:socratic_seminar, :with_topics, date: (i + 1).days.from_now, organization: organization)
        end

        # Create 15 past seminars
        15.times do |i|
          create(:socratic_seminar, :with_topics, date: (i + 1).days.ago, organization: organization)
        end

        get root_path
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "limits upcoming seminars to 10" do
        expect(assigns(:upcoming_seminars).size).to eq(10)
      end

      it "limits past seminars to 10" do
        expect(assigns(:past_seminars).size).to eq(10)
      end

      it "orders upcoming seminars by date ascending" do
        dates = assigns(:upcoming_seminars).map(&:date)
        expect(dates).to eq(dates.sort)
      end

      it "orders past seminars by date descending" do
        dates = assigns(:past_seminars).map(&:date)
        expect(dates).to eq(dates.sort.reverse)
      end
    end

    context "with few events" do
      let!(:upcoming_seminar) { create(:socratic_seminar, :with_topics, date: 1.day.from_now, organization: organization) }
      let!(:past_seminar) { create(:socratic_seminar, :with_topics, date: 1.day.ago, organization: organization) }

      before do
        get root_path
      end

      it "shows all available seminars when under limit" do
        expect(assigns(:upcoming_seminars)).to include(upcoming_seminar)
        expect(assigns(:past_seminars)).to include(past_seminar)
      end
    end
  end

  describe "GET /landing_page" do
    it "returns a successful response" do
      get landing_page_path
      expect(response).to be_successful
    end
  end
end
